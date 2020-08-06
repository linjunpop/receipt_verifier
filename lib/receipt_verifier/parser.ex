defmodule ReceiptVerifier.Parser do
  @moduledoc false

  alias ReceiptVerifier.ResponseData
  alias ReceiptVerifier.AppReceipt
  alias ReceiptVerifier.IAPReceipt
  alias ReceiptVerifier.PendingRenewalReceipt
  alias ReceiptVerifier.Error

  @doc false
  @spec parse_response(map()) :: {:ok, ResponseData.t()} | {:error, Error.t()}
  def parse_response(
        %{
          "status" => 0,
          "environment" => environment,
          "receipt" => receipt,
          "latest_receipt" => latest_receipt
        } = data
      ) do
    {
      :ok,
      %ResponseData{
        environment: environment,
        app_receipt: AppReceipt.parse(receipt),
        base64_latest_app_receipt: latest_receipt,
        latest_iap_receipts: parse_latest_iap_receipts(data),
        pending_renewal_receipts: parse_pending_renewal_info(data),
        raw: data
      }
    }
  end

  def parse_response(%{"status" => 0, "environment" => environment, "receipt" => receipt} = data) do
    {:ok,
     %ResponseData{
       environment: environment,
       app_receipt: AppReceipt.parse(receipt),
       raw: data
     }}
  end

  def parse_response(%{"status" => 0, "receipt" => receipt} = data) do
    {:ok,
      %ResponseData{
        app_receipt: AppReceipt.parse(receipt),
        raw: data
      }
    }
  end

  def parse_response(%{"status" => 21_000}) do
    {:error,
     %Error{code: 21_000, message: "The App Store could not read the JSON object you provided."}}
  end

  def parse_response(%{"status" => 21_002}) do
    {:error,
     %Error{
       code: 21_002,
       message: "The data in the receipt-data property was malformed or missing."
     }}
  end

  def parse_response(%{"status" => 21_003}) do
    {:error, %Error{code: 21_003, message: "The receipt could not be authenticated."}}
  end

  def parse_response(%{"status" => 21_004}) do
    {:error,
     %Error{
       code: 21_004,
       message:
         "The shared secret you provided does not match the shared secret on file for your account."
     }}
  end

  def parse_response(%{"status" => 21_005}) do
    {:error, %Error{code: 21_005, message: "The receipt server is not currently available."}}
  end

  def parse_response(%{"status" => 21_006, "receipt" => _receipt}) do
    {:error,
     %Error{code: 21_006, message: "This receipt is valid but the subscription has expired"}}
  end

  def parse_response(%{"status" => 21_007}) do
    {:error,
     %Error{
       code: 21_007,
       message: "This receipt is from the test environment, but sent to production environment"
     }}
  end

  def parse_response(%{"status" => 21_008}) do
    {:error,
     %Error{
       code: 21_008,
       message: "This receipt is from the production environment, but sent to test environment"
     }}
  end

  def parse_response(%{"status" => 21_009, "environment" => _, "exception" => message}) do
    # seems like an undocumented error by Apple
    # http://stackoverflow.com/questions/37672420/ios-receipt-validation-status-code-21009-what-s-mzinappcacheaccessexception
    {:error, %Error{code: 21_009, message: message}}
  end

  def parse_response(%{"status" => 21_010}) do
    {:error, %Error{code: 21_010, message: "This receipt could not be authorized"}}
  end

  def parse_response(%{"status" => status, "is_retryable" => retry?})
      when status in 21_100..21_199 do
    {:error, %Error{code: status, message: "Internal data access error", meta: [retry?: retry?]}}
  end

  defp parse_latest_iap_receipts(%{"latest_receipt_info" => latest_receipt_info})
       when is_list(latest_receipt_info) do
    latest_receipt_info
    |> Enum.map(&IAPReceipt.parse/1)
  end

  defp parse_latest_iap_receipts(%{"latest_receipt_info" => latest_receipt_info})
       when is_map(latest_receipt_info) do
    IAPReceipt.parse(latest_receipt_info)
  end

  defp parse_latest_iap_receipts(_), do: []

  defp parse_pending_renewal_info(%{"pending_renewal_info" => pending_renewal_info})
       when is_list(pending_renewal_info) do
    pending_renewal_info
    |> Enum.map(&PendingRenewalReceipt.parse/1)
  end

  defp parse_pending_renewal_info(_), do: []
end
