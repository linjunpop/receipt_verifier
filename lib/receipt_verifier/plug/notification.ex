defmodule ReceiptVerifier.Plug.Notification do
  use Plug.Builder

  alias ReceiptVerifier.Plug.DefaultHandler

  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Poison

  @spec init(keyword()) :: keyword()
  def init(opts \\ []) do
    handler_module = Keyword.get(opts, :handler, DefaultHandler)

    [handler: handler_module]
  end

  @spec call(Plug.Conn.t, keyword()) :: Plug.Conn.t
  def call(conn, [handler: handler_module]) do
    conn = super(conn, [])

    case apply(handler_module, :handle_data, [conn, conn.body_params]) do
      :ok ->
        conn
        |> send_resp(200, "")
      {:error, _any} ->
        conn
        |> send_resp(422, "Unprocessable entity")
    end
  end

  defp pre_process_data(conn) do
    params = conn.body_params
  end
end
