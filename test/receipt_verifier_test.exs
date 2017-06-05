defmodule ReceiptVerifierTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  alias ReceiptVerifier.ResponseData

  test "valid receipt" do
    use_cassette "receipt" do
      receipt_file_path = "test/fixtures/receipt"
      base64_receipt =
        receipt_file_path
        |> File.read!
        |> String.replace("\n", "")

      {:ok, %ResponseData{app_receipt: receipt}} = ReceiptVerifier.verify(base64_receipt)

      assert "1241", receipt.application_version
    end
  end

  test "valid auto renewable receipt" do
    use_cassette "auto_renewable_receipt" do
      receipt_file_path = "test/fixtures/auto_renewable_receipt"

      base64_receipt =
        receipt_file_path
        |> File.read!
        |> String.replace("\n", "")

      {:ok, result} = ReceiptVerifier.verify(base64_receipt)

      %ResponseData{app_receipt: app_receipt, latest_iap_receipts: latest_iap_receipts} = result
      latest_iap_receipt = List.last(latest_iap_receipts)

      assert "1241", app_receipt.application_version
      assert "com.sumiapp.GridDiary.pro_subscription", latest_iap_receipt.product_id
    end
  end

  test "invalid receipt" do
    use_cassette "invalid_receipt" do
      base64_receipt = "foobar"

      {:error, %ReceiptVerifier.Error{code: code, message: _}} = ReceiptVerifier.verify(base64_receipt)

      assert 21002 == code
    end
  end
end
