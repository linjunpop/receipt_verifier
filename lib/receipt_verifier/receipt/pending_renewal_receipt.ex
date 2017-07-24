defmodule ReceiptVerifier.PendingRenewalReceipt do
  @moduledoc """
  The struct to represent the pending renewal info

  Example JSON data:
  %{
    "auto_renew_product_id" => "com.sumiapp.GridDiary.pro.subscription",
    "auto_renew_status" => "0",
    "expiration_intent" => "1",
    "is_in_billing_retry_period" => "0",
    "product_id" => "com.sumiapp.GridDiary.pro.subscription"
  }
  """

  @type t :: %__MODULE__{
    auto_renew_product_id: String.t,
    auto_renew_status: String.t,
    expiration_intent: String.t,
    is_in_billing_retry_period: boolean,
    product_id: String.t
  }

  defstruct [
    :auto_renew_product_id,
    :auto_renew_status,
    :expiration_intent,
    :is_in_billing_retry_period,
    :product_id
  ]

  def parse(auto_renewal_infos) when is_list(auto_renewal_infos)do
    auto_renewal_infos
    |> Enum.map(&parse/1)
  end
  def parse(auto_renewal_info) when is_map(auto_renewal_info) do
    attrs =
      auto_renewal_info
      |> Enum.map(&do_parse_field/1)

    struct(__MODULE__, attrs)
  end

  defp do_parse_field({"is_in_billing_retry_period", "0"}) do
    {:is_in_billing_retry_period, false}
  end
  defp do_parse_field({"is_in_billing_retry_period", "1"}) do
    {:is_in_billing_retry_period, true}
  end
  defp do_parse_field({field, value}) do
    {String.to_atom(field), value}
  end
end
