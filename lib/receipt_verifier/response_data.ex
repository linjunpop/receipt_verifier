defmodule ReceiptVerifier.ResponseData do
  @moduledoc """
  The struct represent the response data from App Store
  """

  alias ReceiptVerifier.IAPReceipt
  alias ReceiptVerifier.AppReceipt

  @type t :: %__MODULE__{
    app_receipt: AppReceipt.t,
    base64_latest_app_receipt: String.t,
    latest_iap_receipts: list(IAPReceipt.t),
    latest_expired_receipt: IAPReceipt.t | nil,
    pending_renewal_receipts: list(IAPReceipt.t),
  }

  defstruct [
    app_receipt: nil,
    base64_latest_app_receipt: nil,
    latest_iap_receipts: [],
    latest_expired_receipt: nil,
    pending_renewal_receipts: [],
  ]
end
