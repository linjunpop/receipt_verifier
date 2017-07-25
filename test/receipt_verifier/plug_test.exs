defmodule ReceiptVerifier.PlugTest do
  use ExUnit.Case, async: false
  use Plug.Test

  alias ReceiptVerifier.Plug.Notification

  describe "handle notification" do
    test "sandbox environment" do
      req = %{
        environment: "SANDBOX"
      } |> Poison.encode!

      conn =
        conn(:post, "/foo", req)
        |> put_req_header("content-type", "application/json")

      opts = Notification.init()

      conn = Notification.call(conn, opts)

      assert conn.status == 200
    end
  end
end
