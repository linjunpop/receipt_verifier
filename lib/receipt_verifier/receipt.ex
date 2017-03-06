defmodule ReceiptVerifier.Receipt do
  @moduledoc """
  The receipt struct
  """

  @type t :: %__MODULE__{receipt: map, latest_receipt: binary, latest_receipt_info: [map]}
  defstruct [
    receipt: nil,
    latest_receipt: nil,
    latest_receipt_info: []
  ]
end
