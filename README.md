# ReceiptVerifier

Verify iTunes receipt with the App Store.

⚠️ Only iOS 7 style app receipts is supported.

[![Build
Status](https://travis-ci.org/linjunpop/receipt_verifier.svg)](https://travis-ci.org/linjunpop/receipt_verifier)
[![Hex.pm](https://img.shields.io/hexpm/v/receipt_verifier.svg?maxAge=2592000)](https://hex.pm/packages/receipt_verifier)
[![codebeat badge](https://codebeat.co/badges/8fe288d1-e25c-4b24-bab0-f7d46f915145)](https://codebeat.co/projects/github-com-linjunpop-receipt_verifier-master)
[![Inline docs](http://inch-ci.org/github/linjunpop/receipt_verifier.svg?branch=master)](http://inch-ci.org/github/linjunpop/receipt_verifier)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add receipt_verifier to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:receipt_verifier, "~> 0.6.0"}]
  end
  ```

  2. Ensure receipt_verifier is started before your application:

  ```elixir
  def application do
    [applications: [:receipt_verifier]]
  end
  ```

## Usage

### Verify the receipt with the App Store server.

```elixir
iex> ReceiptVerifier.verify(base64_encoded_receipt_data)
...> %ReceiptVerifier.ResponseData{app_receipt: %ReceiptVerifier.AppReceipt{adam_id: 0,
  app_item_id: 0, application_version: "1241",
  bundle_id: "com.sumiapp.GridDiary", download_id: 0,
  in_app: [%ReceiptVerifier.IAPReceipt{expires_date: nil,
    is_trial_period: false,
    original_purchase_date: %DateTime{calendar: Calendar.ISO, day: 17, hour: 6,
     microsecond: {491000, 6}, minute: 52, month: 1, second: 13, std_offset: 0,
     time_zone: "Etc/UTC", utc_offset: 0, year: 1970, zone_abbr: "UTC"},
    original_transaction_id: "1000000118990828",
    product_id: "com.sumiapp.GridDiary.pro",
    purchase_date: %DateTime{calendar: Calendar.ISO, day: 17, hour: 7,
     microsecond: {546000, 6}, minute: 33, month: 1, second: 48, std_offset: 0,
     time_zone: "Etc/UTC", utc_offset: 0, year: 1970, zone_abbr: "UTC"},
    quantity: 1, transaction_id: "1000000118990828",
    web_order_line_item_id: nil},
   %ReceiptVerifier.IAPReceipt{expires_date: nil, is_trial_period: false,
    original_purchase_date: %DateTime{calendar: Calendar.ISO, day: 17, hour: 7,
     microsecond: {546000, 6}, minute: 33, month: 1, second: 48, std_offset: 0,
     time_zone: "Etc/UTC", utc_offset: 0, year: 1970, zone_abbr: "UTC"},
    original_transaction_id: "1000000122102348",
    product_id: "com.sumiapp.griddiary.test",
    purchase_date: %DateTime{calendar: Calendar.ISO, day: 17, hour: 7,
     microsecond: {546000, 6}, minute: 33, month: 1, second: 48, std_offset: 0,
     time_zone: "Etc/UTC", utc_offset: 0, year: 1970, zone_abbr: "UTC"},
    quantity: 1, transaction_id: "1000000122102348",
    web_order_line_item_id: nil}], original_application_version: "1.0",
  original_purchase_date: %DateTime{calendar: Calendar.ISO, day: 16, hour: 22,
   microsecond: {400000, 6}, minute: 2, month: 1, second: 20, std_offset: 0,
   time_zone: "Etc/UTC", utc_offset: 0, year: 1970, zone_abbr: "UTC"},
  receipt_creation_date: %DateTime{calendar: Calendar.ISO, day: 17, hour: 7,
   microsecond: {546000, 6}, minute: 33, month: 1, second: 48, std_offset: 0,
   time_zone: "Etc/UTC", utc_offset: 0, year: 1970, zone_abbr: "UTC"},
  receipt_type: "ProductionSandbox",
  request_date: %DateTime{calendar: Calendar.ISO, day: 18, hour: 2,
   microsecond: {590831, 6}, minute: 47, month: 1, second: 30, std_offset: 0,
   time_zone: "Etc/UTC", utc_offset: 0, year: 1970, zone_abbr: "UTC"},
  version_external_identifier: 0}, base64_latest_app_receipt: nil,
 latest_iap_receipts: []}
```

### Error handling

If there is error, `ReceiptVerifier.verify/1` 
will return `{:error, %ReceiptVerifier.Error{code: code, message: msg}}`.

An example:

```elixir
{:error, %ReceiptVerifier.Error{code: 21002, message: "The data in the receipt-data property was malformed or missing."}}
```

