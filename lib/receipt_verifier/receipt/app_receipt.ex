defmodule ReceiptVerifier.AppReceipt do
  @moduledoc """
  The struct represent an App Receipt
  """

  alias ReceiptVerifier.IAPReceipt

  @type t :: %__MODULE__{
          adam_id: integer,
          app_item_id: integer,
          application_version: String.t(),
          bundle_id: String.t(),
          download_id: integer,
          expiration_date: DateTime.t(),
          iap_receipts: [IAPReceipt.t()],
          original_application_version: String.t(),
          original_purchase_date: DateTime.t(),
          preorder_date: DateTime.t(),
          receipt_creation_date: DateTime.t(),
          receipt_type: String.t(),
          request_date: DateTime.t(),
          version_external_identifier: integer
        }

  defstruct adam_id: nil,
            app_item_id: nil,
            application_version: nil,
            bundle_id: nil,
            download_id: nil,
            expiration_date: nil,
            iap_receipts: [],
            original_application_version: nil,
            original_purchase_date: nil,
            preorder_date: nil,
            receipt_creation_date: nil,
            receipt_type: nil,
            request_date: nil,
            version_external_identifier: nil

  @doc false
  @spec parse(map) :: t
  def parse(data) when is_map(data) do
    attrs =
      data
      |> Enum.map(&do_parse_field/1)

    struct(__MODULE__, attrs)
  end

  defp do_parse_field({"request_date_ms", value}) do
    {:request_date, format_datetime(value)}
  end

  defp do_parse_field({"request_date", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"request_date_pst", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"receipt_creation_date_ms", value}) do
    {:receipt_creation_date, format_datetime(value)}
  end

  defp do_parse_field({"receipt_creation_date", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"receipt_creation_date_pst", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"original_purchase_date_ms", value}) do
    {:original_purchase_date, format_datetime(value)}
  end

  defp do_parse_field({"original_purchase_date", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"original_purchase_date_pst", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"expiration_date_ms", value}) do
    {:original_purchase_date, format_datetime(value)}
  end

  defp do_parse_field({"expiration_date", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"expiration_date_pst", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"preorder_date_ms", value}) do
    {:original_purchase_date, format_datetime(value)}
  end

  defp do_parse_field({"preorder_date", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"preorder_date_pst", _value}) do
    {:skip, nil}
  end

  defp do_parse_field({"in_app", iaps}) do
    {:iap_receipts, Enum.map(iaps, &IAPReceipt.parse/1)}
  end

  defp do_parse_field({field, value}) do
    {String.to_atom(field), value}
  end

  defp format_datetime(datetime) do
    datetime
    |> String.to_integer()
    |> DateTime.from_unix!(:millisecond)
  end
end
