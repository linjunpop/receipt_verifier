defmodule ReceiptVerifier.Plug.DefaultHandler do
  @behaviour ReceiptVerifier.Plug.Handler

  def handle_data(_conn, data) do
    # TODO: handle data
    :ok
  end
end

