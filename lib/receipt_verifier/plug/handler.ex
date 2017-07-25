defmodule ReceiptVerifier.Plug.Handler do

  @callback handle_data(conn :: Plug.Conn.t, data :: map) :: :ok | {:error, any}
end
