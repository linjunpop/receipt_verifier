defmodule ReceiptVerifier.JSON do
  @moduledoc """
  The module act as an adapter to JSON library

  By default, it use `Jason` to encode JSON, if you want to use `Poison`,
  you can configure `:receipt_verifier` application with:

  ```elixir
  config :receipt_verifier, :json_library, Poison
  ```
  """

  json_lib =
    case Application.get_env(:receipt_verifier, :json_library, Jason) do
      lib when lib in [Jason, Poison] ->
        lib

      other ->
        IO.warn("""
        You has set the JSON Library to `#{other}`, which might not work as expected.

        Currently, only `Jason` and `Poison` are supported,
        you can config it with:

            config :receipt_verifier, :json_library, Jason
        """)

        other
    end

  @json_lib json_lib

  @doc false
  defmacro decode(value) do
    quote do
      unquote(@json_lib).decode(unquote(value))
    end
  end

  @doc false
  defmacro encode!(value) do
    quote do
      unquote(@json_lib).encode!(unquote(value))
    end
  end
end
