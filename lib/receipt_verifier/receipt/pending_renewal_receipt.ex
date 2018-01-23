defmodule ReceiptVerifier.PendingRenewalReceipt do
  @moduledoc """
  The struct to represent the Pending Renewal Receipt

  A pending renewal may refer to a renewal that is scheduled in the future or a renewal that failed in the past for some reason.
  """

  @type t :: %__MODULE__{
          auto_renew_product_id: String.t(),
          auto_renew_status: String.t(),
          expiration_intent: String.t(),
          is_in_billing_retry_period: boolean,
          product_id: String.t()
        }

  defstruct [
    :auto_renew_product_id,
    :auto_renew_status,
    :expiration_intent,
    :is_in_billing_retry_period,
    :product_id
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

  defp do_parse_field({field, value}) do
    {String.to_atom(field), value}
  end
end
