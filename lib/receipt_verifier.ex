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
  """

  alias ReceiptVerifier.Client
  alias ReceiptVerifier.Parser
  alias ReceiptVerifier.ResponseData
  alias ReceiptVerifier.Error

  @typedoc """
  - `env` - *(Optional)* The environment, default to `:auto`
    - `:production` - production environment
    - `:sandbox` - sandbox environment
    - `:auto` - choose the environment automatically, in this mode,
      if you send sandbox receipt to production server, it will be
      automatically resend to test server.
      Same for the production receipt.
  - `exclude_old_transactions` - *(Optional)* Exclude the old transactions
  - `password` - *(Optional)* the shared secret used for auto-renewable subscriptions
  """
  @type options :: [
          env: :production | :sandbox | :auto,
          exclude_old_transactions: boolean(),
          password: String.t()
        ]

  @default_options [
    env: :auto
  ]

  @doc """
  Verify Base64-encoded receipt with the Apple Store
  """
  @spec verify(binary(), options) :: {:ok, ResponseData.t()} | {:error, Error.t()}
  def verify(receipt, opts \\ []) when is_binary(receipt) do
    options =
      @default_options
      |> Keyword.merge(opts)
      |> Enum.into(%{})

    do_verify(receipt, options)
  end

  defp do_verify(receipt, options) when is_map(options) do
    with {:ok, json} <- Client.request(receipt, options),
         {:ok, data} <- Parser.parse_response(json) do
      {:ok, data}
    else
      {:error, %Error{code: code} = error} when code in [21_007, 21_008] ->
        maybe_retry(receipt, error, options)

      {:error, %Error{code: code, meta: meta} = err} when code in 21_100..21_199 ->
        if Keyword.get(meta, :retry?, false) do
          do_verify(receipt, options)
        else
          {:error, err}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp maybe_retry(receipt, error, opts) do
    with :auto <- opts.env do
      case error do
        %Error{code: 21_007} ->
          retry_in_env(receipt, :sandbox, opts)

        %Error{code: 21_008} ->
          retry_in_env(receipt, :production, opts)
      end
    else
      env when env in [:sandbox, :production] ->
        {:error, error}
    end
  end

  defp retry_in_env(receipt, env, opts) do
    opts =
      opts
      |> Map.merge(%{env: env})

    do_verify(receipt, opts)
  end
end
