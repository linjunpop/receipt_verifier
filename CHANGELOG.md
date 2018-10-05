# CHANGELOG

## master

## v0.13.0 

* Change the HTTP Client to hackney.
* Make [Jason](https://github.com/michalmuskala/jason) an optional dependency.
* Requires Elixir 1.4.

## v0.12.2

* Fixes custom JSON adpater not wokring for encoding.

## v0.12.1

* Fixes a retryable response with the error code from 21100 to 21199 may fail to retry.

## v0.12.0

* Make JSON library an optional dependency,
   [Jason](https://github.com/michalmuskala/jason) is recommended.

## v0.11.0

* Allow `Poison ~> 4.0` to be used. Thanks @ericentin.

## v0.10.0

* Added `is_in_intro_offer_period` to `ReceiptVerifier.IAPReceipt`.
* Added `:auto` to the `env` option which make it explicitly to retry in different sandbox and production env.

## v0.9.0

* Added a key `raw` to `ReceiptVerifier.ResponseData`, Thanks @thousandsofthem.

## v0.8.0

* Fixes the retry flag in response for `21199` should be `is_retryable`.
* Handle `21010` status.
* Added `environment` to `%ReceiptVerifier.ResponseData{}`.

## v0.7.0

* Drop config the `shared_secret`, Added `:password` option to
  `ReceiptVerifier.verify/2`
* Fixes if receipt is retyring with 21007 & 20118 status, the options will be
  ignored.

## v0.6.0

* Change `ReceiptVerifier.verify/1` to `ReceiptVerifier.verify/2` which accepts
  an optional `ReceiptVerifier.Client.options`.
* Use `ReceiptVerifier.verify(receipt, exclude_old_transactions: true)` to make
  the `:latest_iap_receipts` in response data only contains the latest item.
* Returns error for the new `21100-21199 Internal data access error`.
* Added new field `:pending_renewal_receipts` to `ReceiptVerifier.ResponseData`

## v0.5.0

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
