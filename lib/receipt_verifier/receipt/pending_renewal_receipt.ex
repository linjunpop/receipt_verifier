defmodule ReceiptVerifier.PendingRenewalReceipt do
  @moduledoc """
  The struct to represent the Pending Renewal Receipt

  A pending renewal may refer to a renewal that is scheduled in the future or a renewal that failed in the past for some reason.
  """

  @type t :: %__MODULE__{
          auto_renew_product_id: String.t(),
          auto_renew_status: String.t(),
          expiration_intent: String.t(),
          grace_period_expires_date: DateTime.t(),
          is_in_billing_retry_period: boolean,
          offer_code_ref_name: String.t(),
          original_transaction_id: String.t(),
          price_consent_status: String.t(),
          product_id: String.t(),
          promotional_offer_id: String.t()
        }

  defstruct [
    :auto_renew_product_id,
    :auto_renew_status,
    :expiration_intent,
    :grace_period_expires_date,
    :is_in_billing_retry_period,
    :offer_code_ref_name,
    :original_transaction_id,
    :price_consent_status,
    :product_id,
    :promotional_offer_id
  ]

  @doc false
  @spec parse(map) :: t
  def parse(data) when is_map(data) do
    attrs =
      data
      |> Enum.map(&do_parse_field/1)

    struct(__MODULE__, attrs)
  end

  defp do_parse_field({"is_in_billing_retry_period", "0"}) do
    {:is_in_billing_retry_period, false}
  end

  defp do_parse_field({"is_in_billing_retry_period", "1"}) do
    {:is_in_billing_retry_period, true}
  end

    defp do_parse_field({"grace_period_expires_date_ms", value}) do
    {:grace_period_expires_date, format_datetime(value)}
  end

  defp do_parse_field({"grace_period_expires_date", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"grace_period_expires_date_pst", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({field, value}) do
    {String.to_atom(field), value}
  end

  defp format_datetime(datetime) do
    datetime
    |> String.to_integer()
    |> DateTime.from_unix!(:millisecond)
  end
end
