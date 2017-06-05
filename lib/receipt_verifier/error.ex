defmodule ReceiptVerifier.Error do
  @moduledoc """
  The error sturct

  The `code` is status code returns from Apple's Server,

  The `message` is the detailed description of the error

  ## Example

      %ReceiptVerifier.Error{code: 21002, message: "The data in the receipt-data property was malformed or missing."}
  """

  @type t :: %__MODULE__{
    code: integer,
    message: any
  }

  defstruct code: nil, message: ""
end
