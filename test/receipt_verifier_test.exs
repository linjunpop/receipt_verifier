defmodule ReceiptVerifierTest do
  use ExUnit.Case
  doctest ReceiptVerifier

  test "the truth" do
    receipt_file_path = "test/fixtures/receipt"
    base64_receipt =
      receipt_file_path
      |> File.read!
      |> String.replace("\n", "")

    {:ok, receipt} = ReceiptVerifier.verify(base64_receipt)

    assert "1241", receipt["application_version"]
  end
end
