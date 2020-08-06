defmodule ReceiptVerifier.IAPReceipt do
  @moduledoc """
  The struct represent an In-App Purchase Receipt
  """

  @type t :: %__MODULE__{
          web_order_line_item_id: String.t(),
          transaction_id: String.t(),
          quantity: integer,
          purchase_date: DateTime.t(),
          product_id: String.t(),
          original_transaction_id: String.t(),
          original_purchase_date: DateTime.t(),
          is_trial_period: boolean(),
          is_in_intro_offer_period: boolean(),
          expires_date: DateTime.t()
        }

  defstruct [
    :web_order_line_item_id,
    :transaction_id,
    :quantity,
    :purchase_date,
    :product_id,
    :original_transaction_id,
    :original_purchase_date,
    :is_trial_period,
    :is_in_intro_offer_period,
    :expires_date
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

  defp do_parse_field({field, value}) do
    {String.to_atom(field), value}
  end

  defp format_datetime(datetime) do
    datetime
    |> String.to_integer()
    |> DateTime.from_unix!(:milliseconds)
  end
end
