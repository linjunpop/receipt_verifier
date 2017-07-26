defmodule ReceiptVerifierTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  alias ReceiptVerifier.ResponseData

  setup_all do
    ExVCR.Config.cassette_library_dir("test/fixtures/vcr_cassettes")
    :ok
  end

  describe "receipt" do
    test "valid receipt" do
      use_cassette "receipt" do
        base64_receipt = read_receipt_file("receipt")

        {:ok, %ResponseData{app_receipt: receipt}} = ReceiptVerifier.verify(base64_receipt)

        assert "1241", receipt.application_version
      end
    end
  end

  describe "auto-renewable receipt" do
    test "app receipt" do
      use_cassette "auto_renewable_receipt" do
        base64_receipt = read_receipt_file("auto_renewable_receipt")

        {:ok, result} = ReceiptVerifier.verify(base64_receipt)

        %ResponseData{app_receipt: app_receipt} = result

        assert "1241", app_receipt.application_version
      end
    end

    test "latest iap receipt" do
      use_cassette "auto_renewable_receipt" do
        base64_receipt = read_receipt_file("auto_renewable_receipt")

        {:ok, result} = ReceiptVerifier.verify(base64_receipt)

        %ResponseData{app_receipt: app_receipt, latest_iap_receipts: latest_iap_receipts} = result
        latest_iap_receipt = List.last(latest_iap_receipts)

        assert 120 == length(latest_iap_receipts)
        assert "1241", app_receipt.application_version
        assert "com.sumiapp.GridDiary.pro_subscription", latest_iap_receipt.product_id
      end
    end

    test "pending renewal receipt" do
      use_cassette "auto_renewable_receipt" do
        base64_receipt = read_receipt_file("auto_renewable_receipt")

        {:ok, result} = ReceiptVerifier.verify(base64_receipt)

        %ResponseData{pending_renewal_receipts: pending_renewal_receipts} = result
        pending_renewal_receipt = List.last(pending_renewal_receipts)

        assert false == pending_renewal_receipt.is_in_billing_retry_period
        assert "com.sumiapp.GridDiary.pro_subscription" == pending_renewal_receipt.auto_renew_product_id
      end
    end
  end

  describe "exclude old iap receipts" do
    test "dont exclude transactions" do
      use_cassette "exclude_old_transactions_false" do
        base64_receipt = read_receipt_file("griddiary_production")

        {:ok, result} = ReceiptVerifier.verify(base64_receipt, exclude_old_transactions: false)

        assert 3 == length(result.latest_iap_receipts)
      end
    end

    test "will exclude old transactions" do
      use_cassette "exclude_old_transactions" do
        base64_receipt = read_receipt_file("griddiary_production")

        {:ok, result} = ReceiptVerifier.verify(base64_receipt, exclude_old_transactions: true)

        assert 1 == length(result.latest_iap_receipts)
      end
    end
  end

  describe "invalid receipt" do
    test "malformed receipt data" do
      use_cassette "invalid_receipt" do
        base64_receipt = "foobar"

        {:error, %ReceiptVerifier.Error{code: code, message: msg}} = ReceiptVerifier.verify(base64_receipt)

        assert 21002 == code
        assert "The data in the receipt-data property was malformed or missing." == msg
      end
    end
  end

  defp read_receipt_file(filename) do
    "test/fixtures/receipts/#{filename}"
    |> File.read!
    |> String.replace("\n", "")
  end
end
