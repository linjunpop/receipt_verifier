defmodule ReceiptVerifierTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start
  end

  test "valid receipt" do
    use_cassette "receipt" do
      receipt_file_path = "test/fixtures/receipt"
      base64_receipt =
        receipt_file_path
        |> File.read!
        |> String.replace("\n", "")

      {:ok, %ReceiptVerifier.Receipt{receipt: receipt}} = ReceiptVerifier.verify(base64_receipt)

      assert "1241", receipt["application_version"]
    end
  end

  test "valid auto renewable receipt" do
    use_cassette "auto_renewable_receipt" do
      receipt_file_path = "test/fixtures/auto_renewable_receipt"

      base64_receipt =
        receipt_file_path
        |> File.read!
        |> String.replace("\n", "")

      {:ok, %ReceiptVerifier.Receipt{receipt: receipt, latest_receipt: latest_receipt, latest_receipt_info: _latest_receipt_info}} = ReceiptVerifier.verify(base64_receipt)

      assert "1241", receipt["application_version"]
      assert latest_receipt
    end
  end
end
