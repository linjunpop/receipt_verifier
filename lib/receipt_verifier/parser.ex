defmodule ReceiptVerifier.Parser do
  @moduledoc """
  The Parser to parse response from App Store
  """

  alias ReceiptVerifier.Receipt
  alias ReceiptVerifier.Error

  @doc """
  Parse the response

  ## Example
      iex> json = %{"status" => 0, "receipt" => receipt, "latest_receipt" => latest_receipt, "latest_receipt_info" => latest_receipt_info}
      iex> {:ok, receipt} = ReceiptVerifier.Parser.parse(json)
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
  """
  @spec parse(map()) :: {:ok, Receipt.t} | {:error, Error.t}
  def parse(%{"status" => 0, "receipt" => receipt, "latest_receipt" => latest_receipt, "latest_receipt_info" => latest_receipt_info}) do
    {:ok, %Receipt{receipt: receipt, latest_receipt: latest_receipt, latest_receipt_info: latest_receipt_info}}
  end
  def parse(%{"status" => 0, "receipt" => receipt}) do
    {:ok, %Receipt{receipt: receipt}}
  end
  def parse(%{"status" => 21_000}) do
    {:error, %Error{code: 21_000, message: "The App Store could not read the JSON object you provided."}}
  end
  def parse(%{"status" => 21_002}) do
    {:error, %Error{code: 21_002, message: "The data in the receipt-data property was malformed or missing."}}
  end
  def parse(%{"status" => 21_003}) do
    {:error, %Error{code: 21_003, message: "The receipt could not be authenticated."}}
  end
  def parse(%{"status" => 21_004}) do
    {:error, %Error{code: 21_004, message: "The shared secret you provided does not match the shared secret on file for your account."}}
  end
  def parse(%{"status" => 21_005}) do
    {:error, %Error{code: 21_005, message: "The receipt server is not currently available."}}
  end
  def parse(%{"status" => 21_006, "receipt" => _receipt}) do
    {:error, %Error{code: 21_006, message: "This receipt is valid but the subscription has expired"}}
  end
  # def parse(%{"status" => 21_007}) do
  #   # This receipt is from the test environment,
  #   # but it was sent to the production environment for verification.
  #   # Send it to the test environment instead.
  #   {:retry, :test}
  # end
  # def parse(%{"status" => 21_008}) do
  #   # This receipt is from the production environment,
  #   # but it was sent to the test environment for verification.
  #   # Send it to the production environment instead.
  #   {:retry, :prod}
  # end
  def parse(%{"environment" => _, "exception" => message, "status" => 21_009}) do
    # seems like an undocumented error by Apple
    # http://stackoverflow.com/questions/37672420/ios-receipt-validation-status-code-21009-what-s-mzinappcacheaccessexception
    {:error, %Error{code: 21_009, message: message}}
  end
end
