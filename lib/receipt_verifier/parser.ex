defmodule ReceiptVerifier.Parser do
  @moduledoc """
  The Parser to parse response from App Store
  """

  alias ReceiptVerifier.ResponseData
  alias ReceiptVerifier.AppReceipt
  alias ReceiptVerifier.IAPReceipt
  alias ReceiptVerifier.Error

  @doc """
  parse the response from App Store

  ## Example
      iex> ReceiptVerifier.Parser.parse(json)
      ...> %ReceiptVerifier.ResponseData{app_receipt: %ReceiptVerifier.AppReceipt{adam_id: 0,
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
       latest_iap_receipts: []}
  """
  @spec parse_response(map()) :: {:ok, ResponseData.t} | {:error, Error.t}
  def parse_response(%{"status" => 0, "receipt" => receipt, "latest_receipt" => latest_receipt, "latest_receipt_info" => latest_receipt_info}) do
    {
      :ok,
      %ResponseData{
        app_receipt: AppReceipt.parse(receipt),
        base64_latest_app_receipt: latest_receipt,
        latest_iap_receipts: IAPReceipt.parse(latest_receipt_info)
      }
    }
  end
  def parse_response(%{"status" => 0, "receipt" => receipt}) do
    {:ok, %ResponseData{app_receipt: AppReceipt.parse(receipt)}}
  end
  def parse_response(%{"status" => 21_000}) do
    {:error, %Error{code: 21_000, message: "The App Store could not read the JSON object you provided."}}
  end
  def parse_response(%{"status" => 21_002}) do
    {:error, %Error{code: 21_002, message: "The data in the receipt-data property was malformed or missing."}}
  end
  def parse_response(%{"status" => 21_003}) do
    {:error, %Error{code: 21_003, message: "The receipt could not be authenticated."}}
  end
  def parse_response(%{"status" => 21_004}) do
    {:error, %Error{code: 21_004, message: "The shared secret you provided does not match the shared secret on file for your account."}}
  end
  def parse_response(%{"status" => 21_005}) do
    {:error, %Error{code: 21_005, message: "The receipt server is not currently available."}}
  end
  def parse_response(%{"status" => 21_006, "receipt" => _receipt}) do
    {:error, %Error{code: 21_006, message: "This receipt is valid but the subscription has expired"}}
  end
  # def parse_response(%{"status" => 21_007}) do
  #   # This receipt is from the test environment,
  #   # but it was sent to the production environment for verification.
  #   # Send it to the test environment instead.
  #   {:retry, :test}
  # end
  # def parse_response(%{"status" => 21_008}) do
  #   # This receipt is from the production environment,
  #   # but it was sent to the test environment for verification.
  #   # Send it to the production environment instead.
  #   {:retry, :prod}
  # end
  def parse_response(%{"environment" => _, "exception" => message, "status" => 21_009}) do
    # seems like an undocumented error by Apple
    # http://stackoverflow.com/questions/37672420/ios-receipt-validation-status-code-21009-what-s-mzinappcacheaccessexception
    {:error, %Error{code: 21_009, message: message}}
  end
end
