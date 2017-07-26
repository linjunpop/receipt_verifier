defmodule ReceiptVerifier.IAPReceipt do
  @moduledoc """
  The struct represent an In-App Purchase Receipt
  """

  @type t :: %__MODULE__{
    web_order_line_item_id: String.t,
    transaction_id: String.t,
    quantity: integer,
    purchase_date: DateTime.t,
    product_id: String.t,
    original_transaction_id: String.t,
    original_purchase_date: DateTime.t,
    is_trial_period: boolean(),
    expires_date: DateTime.t
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
    :expires_date,
  ]

  @doc """
  Parse the IAP Receipt, returns the parsed struct

  ## Example
  ```elixir
  iex> ReceiptVerifier.IAPReceipt.parse(data)
  ...> %ReceiptVerifier.IAPReceipt{expires_date: %DateTime{calendar: Calendar.ISO,
    day: 5, hour: 7, microsecond: {0, 3}, minute: 6, month: 1, second: 6,
    std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2017,
    zone_abbr: "UTC"}, is_trial_period: false,
   original_purchase_date: %DateTime{calendar: Calendar.ISO, day: 6, hour: 1,
    microsecond: {0, 3}, minute: 38, month: 12, second: 52, std_offset: 0,
    time_zone: "Etc/UTC", utc_offset: 0, year: 2016, zone_abbr: "UTC"},
   original_transaction_id: "1000000256351830",
   product_id: "com.sumiapp.GridDiary.pro_subscription",
   purchase_date: %DateTime{calendar: Calendar.ISO, day: 5, hour: 7,
    microsecond: {0, 3}, minute: 1, month: 1, second: 6, std_offset: 0,
    time_zone: "Etc/UTC", utc_offset: 0, year: 2017, zone_abbr: "UTC"},
   quantity: 1, transaction_id: "1000000262887838",
   web_order_line_item_id: "1000000034053495"}
  ```
  """
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
  defp do_parse_field({"original_purchase_date_ms", value}) do
    {:original_purchase_date, format_datetime(value)}
  end
  defp do_parse_field({"is_trial_period", value}) do
    # In elixir, true is :true
    {:is_trial_period, String.to_atom(value)}
  end
  defp do_parse_field({"quantity", value}) do
    {:quantity, String.to_integer(value)}
  end
  defp do_parse_field({"expires_date_ms", value}) do
    {:expires_date, format_datetime(value)}
  end
  defp do_parse_field({field, value}) do
    {String.to_atom(field), value}
  end

  defp format_datetime(datetime) do
    datetime
    |> String.to_integer
    |> DateTime.from_unix!(:milliseconds)
  end
end
