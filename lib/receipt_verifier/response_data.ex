defmodule ReceiptVerifier.ResponseData do
  @moduledoc """
  The struct represent the response data from App Store
  """

  alias ReceiptVerifier.IAPReceipt
  alias ReceiptVerifier.AppReceipt

  @type t :: %__MODULE__{
          environment: String.t(),
          app_receipt: AppReceipt.t(),
          base64_latest_app_receipt: String.t(),
          latest_iap_receipts: list(IAPReceipt.t()),
          pending_renewal_receipts: list(IAPReceipt.t()),
          raw: map()
        }

  defstruct environment: nil,
            app_receipt: nil,
            base64_latest_app_receipt: nil,
            latest_iap_receipts: [],
            pending_renewal_receipts: [],
            raw: nil
end
