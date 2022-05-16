defmodule ReceiptVerifier.IAPReceipt do
  @moduledoc """
  The struct represent an In-App Purchase Receipt
  """

  @type t :: %__MODULE__{
          cancellation_date: DateTime.t(),
          cancellation_reason: integer,
          expires_date: DateTime.t(),
          in_app_ownership_type: String.t(),
          is_in_intro_offer_period: boolean(),
          is_trial_period: boolean(),
          is_upgraded: boolean(),
          offer_code_ref_name: String.t(),
          original_purchase_date: DateTime.t(),
          original_transaction_id: String.t(),
          product_id: String.t(),
          promotional_offer_id: String.t(),
          purchase_date: DateTime.t(),
          quantity: integer,
          subscription_group_identifier: String.t(),
          web_order_line_item_id: String.t(),
          transaction_id: String.t()
        }

  defstruct [
    :cancellation_date,
    :cancellation_reason,
    :expires_date,
    :in_app_ownership_type,
    :is_in_intro_offer_period,
    :is_trial_period,
    :offer_code_ref_name,
    :original_purchase_date,
    :original_transaction_id,
    :product_id,
    :promotional_offer_id,
    :purchase_date,
    :quantity,
    :subscription_group_identifier,
    :web_order_line_item_id,
    :transaction_id,
    is_upgraded: false
  ]

  @doc false
  @spec parse(map) :: t
  def parse(data) when is_map(data) do
    attrs =
      data
      |> Enum.map(&do_parse_field/1)

    struct(__MODULE__, attrs)
  end

  defp do_parse_field({"purchase_date_ms", value}) do
    {:purchase_date, format_datetime(value)}
  end

  defp do_parse_field({"purchase_date", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"purchase_date_pst", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"original_purchase_date_ms", value}) do
    {:original_purchase_date, format_datetime(value)}
  end

  defp do_parse_field({"original_purchase_date", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"original_purchase_date_pst", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"is_trial_period", value}) do
    # In elixir, true is :true
    {:is_trial_period, String.to_atom(value)}
  end

  defp do_parse_field({"is_in_intro_offer_period", value}) do
    {:is_in_intro_offer_period, String.to_atom(value)}
  end

  defp do_parse_field({"quantity", value}) do
    {:quantity, String.to_integer(value)}
  end

  defp do_parse_field({"expires_date_ms", value}) do
    {:expires_date, format_datetime(value)}
  end

  defp do_parse_field({"expires_date", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"expires_date_pst", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"cancellation_date_ms", value}) do
    {:cancellation_date, format_datetime(value)}
  end

  defp do_parse_field({"cancellation_date", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"cancellation_date_pst", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"cancellation_reason", nil}) do
    {:cancellation_reason, nil}
  end

  defp do_parse_field({"cancellation_reason", value}) do
    {:cancellation_reason, String.to_integer(value)}
  end

  defp do_parse_field({"is_upgraded", value}) do
    # In elixir, true is :true
    {:is_upgraded, String.to_atom(value)}
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
