defmodule ReceiptVerifier.AppReceipt do
  @moduledoc """
  The struct represent an App Receipt
  """

  alias ReceiptVerifier.IAPReceipt

  @type t :: %__MODULE__{
    version_external_identifier: integer,
    request_date: DateTime.t,
    receipt_type: String.t,
    receipt_creation_date: DateTime.t,
    original_purchase_date: DateTime.t,
    original_application_version: String.t,
    download_id: integer,
    bundle_id: String.t,
    application_version: String.t,
    app_item_id: integer,
    adam_id: integer,
    iap_receipts: [IAPReceipt.t],
  }

  defstruct [
    version_external_identifier: nil,
    request_date: nil,
    receipt_type: nil,
    receipt_creation_date: nil,
    original_purchase_date: nil,
    original_application_version: nil,
    download_id: nil,
    bundle_id: nil,
    application_version: nil,
    app_item_id: nil,
    adam_id: nil,
    iap_receipts: [],
  ]

  @doc """
  Parse the App Receipt, returns the parsed struct

  ## Example
  ```elixir
  iex> ReceiptVerifier.AppReceipt.parse(json)
  ...> %ReceiptVerifier.AppReceipt{adam_id: 0, app_item_id: 0,
   application_version: "1241", bundle_id: "com.sumiapp.GridDiary",
   download_id: 0,
   in_app: [%ReceiptVerifier.IAPReceipt{expires_date: nil, is_trial_period: false,
     original_purchase_date: %DateTime{calendar: Calendar.ISO, day: 17, hour: 6,
      microsecond: {491000, 6}, minute: 52, month: 1, second: 13, std_offset: 0,
      time_zone: "Etc/UTC", utc_offset: 0, year: 1970, zone_abbr: "UTC"},
     original_transaction_id: "1000000118990828",
     product_id: "com.sumiapp.GridDiary.pro",
     purchase_date: %DateTime{calendar: Calendar.ISO, day: 17, hour: 7,
      microsecond: {546000, 6}, minute: 33, month: 1, second: 48, std_offset: 0,
      time_zone: "Etc/UTC", utc_offset: 0, year: 1970, zone_abbr: "UTC"},
     quantity: 1, transaction_id: "1000000118990828",
     web_order_line_item_id: nil},
    %ReceiptVerifier.IAPReceipt{expires_date: nil, is_trial_period: false,
     original_purchase_date: %DateTime{calendar: Calendar.ISO, day: 17, hour: 7,
      microsecond: {546000, 6}, minute: 33, month: 1, second: 48, std_offset: 0,
      time_zone: "Etc/UTC", utc_offset: 0, year: 1970, zone_abbr: "UTC"},
     original_transaction_id: "1000000122102348",
     product_id: "com.sumiapp.griddiary.test",
     purchase_date: %DateTime{calendar: Calendar.ISO, day: 17, hour: 7,
      microsecond: {546000, 6}, minute: 33, month: 1, second: 48, std_offset: 0,
      time_zone: "Etc/UTC", utc_offset: 0, year: 1970, zone_abbr: "UTC"},
     quantity: 1, transaction_id: "1000000122102348",
     web_order_line_item_id: nil}], original_application_version: "1.0",
   original_purchase_date: %DateTime{calendar: Calendar.ISO, day: 16, hour: 22,
    microsecond: {400000, 6}, minute: 2, month: 1, second: 20, std_offset: 0,
    time_zone: "Etc/UTC", utc_offset: 0, year: 1970, zone_abbr: "UTC"},
   receipt_creation_date: %DateTime{calendar: Calendar.ISO, day: 17, hour: 7,
    microsecond: {546000, 6}, minute: 33, month: 1, second: 48, std_offset: 0,
    time_zone: "Etc/UTC", utc_offset: 0, year: 1970, zone_abbr: "UTC"},
   receipt_type: "ProductionSandbox",
   request_date: %DateTime{calendar: Calendar.ISO, day: 18, hour: 2,
    microsecond: {590831, 6}, minute: 47, month: 1, second: 30, std_offset: 0,
    time_zone: "Etc/UTC", utc_offset: 0, year: 1970, zone_abbr: "UTC"},
   version_external_identifier: 0}
  ```
  """
  @spec parse(map) :: t
  def parse(data) when is_map(data) do
    attrs =
      data
      |> Enum.map(&do_parse_field/1)

    struct(__MODULE__, attrs)
  end

  defp do_parse_field({"request_date_ms", value}) do
    {:request_date, format_datetime(value)}
  end
  defp do_parse_field({"receipt_creation_date_ms", value}) do
    {:receipt_creation_date, format_datetime(value)}
  end
  defp do_parse_field({"original_purchase_date_ms", value}) do
    {:original_purchase_date, format_datetime(value)}
  end
  defp do_parse_field({"in_app", iaps}) do
    {:iap_receipts, Enum.map(iaps, &IAPReceipt.parse/1)}
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
