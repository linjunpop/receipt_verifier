defmodule ReceiptVerifierTest do
  use ExUnit.Case
  doctest ReceiptVerifier

  test "the truth" do
    receipt_file_path = "test/fixtures/receipt"
    receipt =
      receipt_file_path
      |> File.read!
      |> String.replace("\n", "")

    result = ReceiptVerifier.verify(receipt)
    {:ok, %{"application_version" => version}} = result

    assert "1241", version
  end
end
