# Getting Started

## Installation

Simply add receipt_verifier to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:receipt_verifier, "~> 0.11.0"}
  ]
end
```

then run `mix deps.get` and you are ready to go.

## Usage

The main interface is `ReceiptVerifier.verify/2`, which accepts a Base64-Encoded
receipt data and an optional option.

### Options:

- `env` - *(Optional)* The environment, default to `:auto`
  - `:production` - production environment
  - `:sandbox` - sandbox environment
  - `:auto` - choose the environment automatically, in this mode,
    if you send sandbox receipt to production server, it will be
    automatically resend to test server.
    Same for the production receipt.
- `exclude_old_transactions` - *(Optional)* Exclude the old transactions
- `password` - *(Optional)* the shared secret used for auto-renewable subscriptions

### Validate a receipt with App Store

```elixir
iex> ReceiptVerifier.verify(BASE64_ENCODED_RECEIPT_DATA, env: :production)
%ReceiptVerifier.ResponseData{app_receipt: %ReceiptVerifier.AppReceipt{adam_id: 0,
  app_item_id: 0, application_version: "1241",
  bundle_id: "com.sumiapp.GridDiary", download_id: 0,
  iap_receipts: [%ReceiptVerifier.IAPReceipt{expires_date: nil,
    is_trial_period: false,
    original_purchase_date: #DateTime<2014-08-04 06:24:51.000Z>,
    original_transaction_id: "1000000118990828",
    product_id: "com.sumiapp.GridDiary.pro",
    purchase_date: #DateTime<2014-09-02 03:29:06.000Z>, quantity: 1,
    transaction_id: "1000000118990828", web_order_line_item_id: nil},
   %ReceiptVerifier.IAPReceipt{expires_date: nil, is_trial_period: false,
    original_purchase_date: #DateTime<2014-09-02 03:29:06.000Z>,
    original_transaction_id: "1000000122102348",
    product_id: "com.sumiapp.griddiary.test",
    purchase_date: #DateTime<2014-09-02 03:29:06.000Z>, quantity: 1,
    transaction_id: "1000000122102348", web_order_line_item_id: nil}],
  original_application_version: "1.0",
  original_purchase_date: #DateTime<2013-08-01 07:00:00.000Z>,
  receipt_creation_date: #DateTime<2014-09-02 03:29:06.000Z>,
  receipt_type: "ProductionSandbox",
  request_date: #DateTime<2016-11-11 07:49:50.831Z>,
  version_external_identifier: 0}, base64_latest_app_receipt: nil,
 environment: "Sandbox", latest_iap_receipts: [], pending_renewal_receipts: []}
```
