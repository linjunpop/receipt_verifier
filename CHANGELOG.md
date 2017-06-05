# CHANGELOG

## master

* Now receipts are parsed as `ReceiptVerifier.AppReceipt` and
  `ReceiptVerifier.IAPReceipt` struct with essential fields,
  instead of a giant Map struct.
* Extract `ReceiptVerifier.Client` and `ReceiptVerifier.Parser` module.
* Fixes `shared_secret` should be an optional config.
* Drop support for Elixir 1.2. (`with ... else` is awesome)

## v0.4.0

* Handle error with code 21009.

## v0.3.0

* Support Elixir 1.4
* Drop denpendency on `HTTPoison`, use `:httpc` instead.

## v0.2.0

* Set latest_receipt_info's default to `[]`.

## v0.1.0

* Support auto-renewable subscriptions.
* Handle 503 Service Unavaliable.

## v0.0.1

* Initial release.
