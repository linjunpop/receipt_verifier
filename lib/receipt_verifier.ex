defmodule ReceiptVerifier do
  @moduledoc """
  Verify iTunes receipt with the Apple Store

  ## Example
      iex> {:ok, receipt} = ReceiptVerifier.verify(base64_encoded_receipt_data)
      ...> receipt =
        %ReceiptVerifier.Receipt{receipt: {"adam_id" => 0, "app_item_id" => 0, "application_version" => "1241",
          "bundle_id" => "com.sumiapp.GridDiary", "download_id" => 0,
          "in_app" => [%{"is_trial_period" => "false",
             "original_purchase_date" => "2014-08-04 06:24:51 Etc/GMT",
             "original_purchase_date_ms" => "1407133491000",
             "original_purchase_date_pst" => "2014-08-03 23:24:51 America/Los_Angeles",
             "original_transaction_id" => "1000000118990828",
             "product_id" => "com.sumiapp.GridDiary.pro",
             "purchase_date" => "2014-09-02 03:29:06 Etc/GMT",
             "purchase_date_ms" => "1409628546000",
             "purchase_date_pst" => "2014-09-01 20:29:06 America/Los_Angeles",
             "quantity" => "1", "transaction_id" => "1000000118990828"},
           %{"is_trial_period" => "false",
             "original_purchase_date" => "2014-09-02 03:29:06 Etc/GMT",
             "original_purchase_date_ms" => "1409628546000",
             "original_purchase_date_pst" => "2014-09-01 20:29:06 America/Los_Angeles",
             "original_transaction_id" => "1000000122102348",
             "product_id" => "com.sumiapp.griddiary.test",
             "purchase_date" => "2014-09-02 03:29:06 Etc/GMT",
             "purchase_date_ms" => "1409628546000",
             "purchase_date_pst" => "2014-09-01 20:29:06 America/Los_Angeles",
             "quantity" => "1", "transaction_id" => "1000000122102348"}],
          "original_application_version" => "1.0",
          "original_purchase_date" => "2013-08-01 07:00:00 Etc/GMT",
          "original_purchase_date_ms" => "1375340400000",
          "original_purchase_date_pst" => "2013-08-01 00:00:00 America/Los_Angeles",
          "receipt_creation_date" => "2014-09-02 03:29:06 Etc/GMT",
          "receipt_creation_date_ms" => "1409628546000",
          "receipt_creation_date_pst" => "2014-09-01 20:29:06 America/Los_Angeles",
          "receipt_type" => "ProductionSandbox",
          "request_date" => "2016-04-29 07:52:28 Etc/GMT",
          "request_date_ms" => "1461916348197",
          "request_date_pst" => "2016-04-29 00:52:28 America/Los_Angeles",
          "version_external_identifier" => 0}}

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
      {:ok, data} <- Parser.parse(json)
    ) do
      {:ok, data}
    else
      any -> any
    end
  end
end
