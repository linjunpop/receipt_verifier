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

  alias ReceiptVerifier.Receipt
  alias ReceiptVerifier.Error

  @production_url 'https://buy.itunes.apple.com/verifyReceipt'
  @sandbox_url 'https://sandbox.itunes.apple.com/verifyReceipt'

  @doc "Verify receipt with a specific server"
  @spec verify(binary, :prod | :test) :: {:ok, Receipt.t} | {:error, Error.t}
  def verify(receipt, env \\ :prod) when env in [:test, :prod] do
    do_verify_receipt(receipt, env)
  end

  defp do_verify_receipt(receipt, :prod) do
    do_request(receipt, @production_url)
  end
  defp do_verify_receipt(receipt, :test) do
    do_request(receipt, @sandbox_url)
  end

  defp do_request(receipt, url) do
    request_body = prepare_request_body(receipt)
    content_type = 'application/json'
    request_headers = [
      {'Accept', 'application/json'}
    ]

    case :httpc.request(:post, {url, request_headers, content_type, request_body}, [], []) do
      {:ok, {{_, 200, _}, _, body}} ->
        data = Poison.decode!(body)
        case process_response(data) do
          {:retry, env} -> do_verify_receipt(receipt, env)
          any -> any
        end
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp prepare_request_body(receipt) do
    %{
      "receipt-data" => receipt,
      "password" => load_password
    } |> Poison.encode!
  end

  defp process_response(%{"status" => 0, "receipt" => receipt, "latest_receipt" => latest_receipt, "latest_receipt_info" => latest_receipt_info}) do
    {:ok, %Receipt{receipt: receipt, latest_receipt: latest_receipt, latest_receipt_info: latest_receipt_info}}
  end
  defp process_response(%{"status" => 0, "receipt" => receipt}) do
    {:ok, %Receipt{receipt: receipt}}
  end
  defp process_response(%{"status" => 21000}) do
    {:error, %Error{code: 21000, message: "The App Store could not read the JSON object you provided."}}
  end
  defp process_response(%{"status" => 21002}) do
    {:error, %Error{code: 21002, message: "The data in the receipt-data property was malformed or missing."}}
  end
  defp process_response(%{"status" => 21003}) do
    {:error, %Error{code: 21003, message: "The receipt could not be authenticated."}}
  end
  defp process_response(%{"status" => 21004}) do
    {:error, %Error{code: 21004, message: "The shared secret you provided does not match the shared secret on file for your account."}}
  end
  defp process_response(%{"status" => 21005}) do
    {:error, %Error{code: 21005, message: "The receipt server is not currently available."}}
  end
  defp process_response(%{"status" => 21006, "receipt" => receipt}) do
    {:error, %Error{code: 21006, message: "This receipt is valid but the subscription has expired"}, receipt: receipt}
  end
  defp process_response(%{"status" => 21007}) do
    # This receipt is from the test environment,
    # but it was sent to the production environment for verification.
    # Send it to the test environment instead.
    {:retry, :test}
  end
  defp process_response(%{"status" => 21008}) do
    # This receipt is from the production environment,
    # but it was sent to the test environment for verification.
    # Send it to the production environment instead.
    {:retry, :prod}
  end

  defp load_password do
    Application.get_env(:receipt_verifier, :shared_secret, "")
  end
end
