defmodule ReceiptVerifier do
  @moduledoc """
  Verify iTunes receipt with the Apple Store

  ## Example
      iex> ReceiptVerifier.verify(base64_encoded_receipt_data)
      {:ok, %ReceiptVerifier.ResponseData{app_receipt: %ReceiptVerifier.AppReceipt{adam_id: 0,
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
  alias ReceiptVerifier.ResponseData
  alias ReceiptVerifier.Error

  @typedoc """
  - `env` - The environment, default to `:production`
    - `:production` - production environment
    - `:sandbox` - sandbox environment
  - `exclude_old_transactions` - Exclude the old transactions
  - `password` - the shared secret
  - `raw` - if true, return response data as raw map, in case of success
  """
  @type options :: [
    env: :production | :sandbox,
    exclude_old_transactions: boolean(),
    password: String.t
  ]

  @doc """
  Verify Base64-encoded receipt with the Apple Store
  """
  @spec verify(String.t, options) :: {:ok, ResponseData.t} | {:error, Error.t}
  def verify(receipt, opts \\ []) when is_binary(receipt) do
    with(
      {:ok, json} <- Client.request(receipt, opts),
      {:ok, data} <- parse(json, opts)
    ) do
      {:ok, data}
    else
      {:error, %Error{code: 21_007}} ->
        retry_in_env(receipt, :sandbox, opts)
      {:error, %Error{code: 21_008}} ->
        retry_in_env(receipt, :production, opts)
      {:error, %Error{code: code, message: msg, meta: meta}} when code in 21_100..21_199 ->
        if Keyword.get(meta, :retry?) do
          verify(receipt, opts)
        else
          {:error, %Error{code: code, message: msg}}
        end
      {:error, reason} -> {:error, reason}
    end
  end

  defp retry_in_env(receipt, env, opts) do
    opts =
      opts
      |> Keyword.merge(env: env)

    verify(receipt, opts)
  end

  defp parse(json, opts) do
    case Parser.parse_response(json) do
      {:ok, data} -> if opts[:raw], do: {:ok, json}, else: {:ok, data}
      {:error, error} -> {:error, error}
    end
  end
end
