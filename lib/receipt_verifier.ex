defmodule ReceiptVerifier do
  @moduledoc """
  Verify iTunes receipt with the Apple Store

  ## Example
      iex> ReceiptVerifier.verify(base64_encoded_receipt_data)
      ...> {:ok, %ReceiptVerifier.ResponseData{app_receipt: %ReceiptVerifier.AppReceipt{adam_id: 0,
        app_item_id: 0, application_version: "1241",
        bundle_id: "com.sumiapp.GridDiary", download_id: 0,
        in_app: [%ReceiptVerifier.IAPReceipt{expires_date: nil,
          is_trial_period: false,
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
        version_external_identifier: 0}, base64_latest_app_receipt: nil,
       latest_iap_receipts: []}}

  > Note: If you send sandbox receipt to production server, it will be auto resend to test server. Same for the production receipt.
  """

  alias ReceiptVerifier.Client
  alias ReceiptVerifier.Parser
  alias ReceiptVerifier.Receipt
  alias ReceiptVerifier.Error

  @doc "Verify receipt with a specific server"
  @spec verify(String.t) :: {:ok, Receipt.t} | {:error, Error.t}
  def verify(receipt) when is_binary(receipt) do
    with(
      {:ok, json} <- Client.request(receipt),
      {:ok, data} <- Parser.parse_response(json)
    ) do
      {:ok, data}
    else
      any -> any
    end
  end
end
