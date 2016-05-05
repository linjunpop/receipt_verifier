defmodule ReceiptVerifier do
  alias ReceiptVerifier.Error

  @production_url "https://buy.itunes.apple.com/verifyReceipt"
  @sandbox_url "https://sandbox.itunes.apple.com/verifyReceipt"

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
    case HTTPoison.post url, prepare_request_body(receipt), request_headers do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        data = Poison.decode!(body)

        case process_response(data) do
          {:retry, env} -> do_verify_receipt(receipt, env)
          any -> any
        end
      {:ok, %HTTPoison.Response{status_code: 503}} ->
        {:error, %Error{code: 503, message: "Service Unavailable"}}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp request_headers do
    [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]
  end

  defp prepare_request_body(receipt) do
    %{
      "receipt-data" => receipt
    } |> Poison.encode!
  end

  defp process_response(%{"status" => 0, "receipt" => receipt}) do
    {:ok, receipt}
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
end
