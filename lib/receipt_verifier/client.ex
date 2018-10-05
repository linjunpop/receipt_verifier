defmodule ReceiptVerifier.Client do
  @moduledoc false

  alias ReceiptVerifier.Error
  alias ReceiptVerifier.JSON

  require JSON

  @endpoints [
    production: "https://buy.itunes.apple.com/verifyReceipt",
    sandbox: "https://sandbox.itunes.apple.com/verifyReceipt"
  ]

  @doc """
  Send the iTunes receipt to Apple Store, and parse the response as map
  """
  @spec request(String.t(), map) :: {:ok, map} | {:error, any}
  def request(receipt, opts) do
    with {:ok, 200, _headers, client_ref} <- do_request(receipt, opts),
         {:ok, body} <- :hackney.body(client_ref),
         {:ok, json} <- JSON.decode(body) do
      {:ok, json}
    else
      {:ok, status_code, _headers, client_ref} ->
        {:ok, msg} = :hackney.body(client_ref)
        {:error, %Error{code: status_code, message: msg}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp do_request(receipt, opts) do
    url = get_endpoint_url(opts.env)

    request_body = prepare_request_body(receipt, opts)

    request_headers = [
      {"content-type", "application/json"},
      {"accept", "application/json"}
    ]

    options = [
      {:pool, :receipt_verifier_hackney}
    ]

    :hackney.request(:post, url, request_headers, request_body, options)
  end

  defp get_endpoint_url(env) when env in [:sandbox, :production] do
    @endpoints
    |> Keyword.get(env)
  end

  defp get_endpoint_url(:auto) do
    @endpoints
    |> Keyword.get(:production)
  end

  defp prepare_request_body(receipt, opts) do
    %{
      "receipt-data" => receipt
    }
    |> maybe_set_password(opts)
    |> maybe_set_exclude_old_transactions(opts)
    |> JSON.encode!()
  end

  defp maybe_set_password(data, opts) do
    case Map.get(opts, :password) do
      nil ->
        data

      password ->
        data
        |> Map.put("password", password)
    end
  end

  defp maybe_set_exclude_old_transactions(data, opts) do
    case Map.get(opts, :exclude_old_transactions) do
      nil ->
        data

      exclude_old_transactions ->
        data
        |> Map.put("exclude-old-transactions", exclude_old_transactions)
    end
  end
end
