# ReceiptVerifier

Verify iTunes receipt with the App Store.

[![Build
Status](https://travis-ci.org/linjunpop/receipt_verifier.svg)](https://travis-ci.org/linjunpop/receipt_verifier)
[![Hex.pm](https://img.shields.io/hexpm/v/receipt_verifier.svg?maxAge=2592000)](https://hex.pm/packages/receipt_verifier)
[![Inline docs](http://inch-ci.org/github/linjunpop/receipt_verifier.svg?branch=master)](http://inch-ci.org/github/linjunpop/receipt_verifier)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add receipt_verifier to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:receipt_verifier, "~> 0.2.0"}]
  end
  ```

  2. Ensure receipt_verifier is started before your application:

  ```elixir
  def application do
    [applications: [:receipt_verifier]]
  end
  ```

## Usage

### Configuration

> you can ignore this if you dont have auto-renewable product

Follow [this guide](https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/iTunesConnectInAppPurchase_Guide/Chapters/CreatingInAppPurchaseProducts.html#//apple_ref/doc/uid/TP40013727-CH3-SW2) to generate a shared secret, then config the `:receipt_verifier` application with:

```elixir
use Mix.Config

config :receipt_verifier,
  shared_secret: "my-secret"
```

### Verify the receipt with the App Store

```elixir
{:ok, result} = ReceiptVerifier.verify(base64_encoded_receipt_data)

%ReceiptVerifier.Receipt{receipt: receipt, latest_receipt: latest_receipt, latest_receipt_info: latest_receipt_info} = result

receipt = %{"adam_id" => 0, "app_item_id" => 0, "application_version" => "1241",
  "bundle_id" => "com.sumiapp.GridDiary", "download_id" => 0,
  "in_app" => [%{"is_trial_period" => "false",
     "original_purchase_date" => "2014-08-04 06:24:51 Etc/GMT",
     "original_purchase_date_ms" => "1407133491000",
     "original_purchase_date_pst" => "2014-08-03 23:24:51 America/Los_Angeles",
     "original_transaction_id" => "1000000118990828",
     "product_id" => "com.sumiapp.GridDiary.pro",
     "purchase_date" => "2014-09-02 03:29:06 Etc/GMT",
     "purchase_date_ms" => "1409628546000",
     "purchase_date_pst" => "2014-09-01 20:29:06 America/Los_Angeles",
     "quantity" => "1", "transaction_id" => "1000000118990828"},
   %{"is_trial_period" => "false",
     "original_purchase_date" => "2014-09-02 03:29:06 Etc/GMT",
     "original_purchase_date_ms" => "1409628546000",
     "original_purchase_date_pst" => "2014-09-01 20:29:06 America/Los_Angeles",
     "original_transaction_id" => "1000000122102348",
     "product_id" => "com.sumiapp.griddiary.test",
     "purchase_date" => "2014-09-02 03:29:06 Etc/GMT",
     "purchase_date_ms" => "1409628546000",
     "purchase_date_pst" => "2014-09-01 20:29:06 America/Los_Angeles",
     "quantity" => "1", "transaction_id" => "1000000122102348"}],
  "original_application_version" => "1.0",
  "original_purchase_date" => "2013-08-01 07:00:00 Etc/GMT",
  "original_purchase_date_ms" => "1375340400000",
  "original_purchase_date_pst" => "2013-08-01 00:00:00 America/Los_Angeles",
  "receipt_creation_date" => "2014-09-02 03:29:06 Etc/GMT",
  "receipt_creation_date_ms" => "1409628546000",
  "receipt_creation_date_pst" => "2014-09-01 20:29:06 America/Los_Angeles",
  "receipt_type" => "ProductionSandbox",
  "request_date" => "2016-04-29 07:52:28 Etc/GMT",
  "request_date_ms" => "1461916348197",
  "request_date_pst" => "2016-04-29 00:52:28 America/Los_Angeles",
  "version_external_identifier" => 0}
```

### Error handling

If there is error, `ReceiptVerifier.verify/1` will return `{:error, %ReceiptVerifier.Error{}}`.

An example:

```elixir
{:error, %ReceiptVerifier.Error{code: 21002, message: "The data in the receipt-data property was malformed or missing."}}
```

