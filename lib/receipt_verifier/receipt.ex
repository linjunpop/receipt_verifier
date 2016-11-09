defmodule ReceiptVerifier.Receipt do
  @type t :: %__MODULE__{receipt: map, latest_receipt: binary, latest_receipt_info: [map]}
  defstruct [:receipt, :latest_receipt, :latest_receipt_info]
end
