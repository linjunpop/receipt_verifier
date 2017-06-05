defmodule ReceiptVerifier.Client do
  @moduledoc """
  The HTTP Client to send request to App Store
  """

  alias ReceiptVerifier.Error

  @production "https://buy.itunes.apple.com/verifyReceipt"
  @sandbox "https://sandbox.itunes.apple.com/verifyReceipt"

  @doc """
  Send the iTunes receipt to Apple Store, and parse the response as map

  ## Example
      iex> {:ok, receipt} = ReceiptVerifier.Client.reuqest(base64_encoded_receipt_data)
      ...> receipt = %{"status" => 0, "receipt" => receipt, "latest_receipt" => latest_receipt, "latest_receipt_info" => latest_receipt_info}

  > Note: If you send sandbox receipt to production server, it will be auto resend to test server. Same for the production receipt.
  
  """
  @spec request(String.t, String.t) :: {:ok, map} | {:error, any}
  def request(receipt, endpoint \\ @production) do
    with(
      {:ok, {{_, 200, _}, _, body}} <- do_request(receipt, endpoint),
      {:ok, json} <- Poison.decode(body),
      :ok <- validate_env(json)
    ) do
      {:ok, json}
    else
      {:error, :invalid} ->
        # Poison error
        {:error, %Error{code: 502, message: "The response from Apple's Server is malformed"}}
      {:error, {:invalid, msg}} ->
        # Poison error
        {:error, %Error{code: 502, message: "The response from Apple's Server is malformed: #{msg}"}}
      {:retry, endpoint} ->
        request(receipt, endpoint)
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp validate_env(%{"status" => 21_007}) do
    # This receipt is from the test environment,
    # but it was sent to the production environment for verification.
    # Send it to the test environment instead.
    {:retry, @sandbox}
  end
  defp validate_env(%{"status" => 21_008}) do
    # This receipt is from the production environment,
    # but it was sent to the test environment for verification.
    # Send it to the production environment instead.
    {:retry, @production}
  end
  defp validate_env(_) do
    :ok
  end

  defp do_request(receipt, url) do
    url = String.to_charlist(url)
    request_body = prepare_request_body(receipt)
    content_type = 'application/json'
    request_headers = [
      {'Accept', 'application/json'}
    ]

    :httpc.request(:post, {url, request_headers, content_type, request_body}, [], [])
  end

  defp prepare_request_body(receipt) do
    %{
      "receipt-data" => receipt
    }
    |> set_password()
    |> Poison.encode!
  end

  defp set_password(data) do
    case Application.get_env(:receipt_verifier, :shared_secret) do
      nil ->
        data
      shared_secret ->
        data
        |> Map.put("password", shared_secret)
    end
  end
end
