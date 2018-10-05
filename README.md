# ReceiptVerifier

Verify iOS App receipt with the App Store.

⚠️ Only iOS 7 style app receipt is supported.

[![Build
Status](https://travis-ci.org/linjunpop/receipt_verifier.svg)](https://travis-ci.org/linjunpop/receipt_verifier)
[![Hex.pm](https://img.shields.io/hexpm/v/receipt_verifier.svg?maxAge=2592000)](https://hex.pm/packages/receipt_verifier)
[![codebeat badge](https://codebeat.co/badges/8fe288d1-e25c-4b24-bab0-f7d46f915145)](https://codebeat.co/projects/github-com-linjunpop-receipt_verifier-master)
[![Inline docs](http://inch-ci.org/github/linjunpop/receipt_verifier.svg?branch=master)](http://inch-ci.org/github/linjunpop/receipt_verifier)

## Installation

Simply add `receipt_verifier` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:receipt_verifier, "~> 0.13"},
    {:jason, "~> 1.0"}
  ]
end
```

then run `mix deps.get` and you are ready to go.

## Usage

```elixir
ReceiptVerifier.verify(BASE64_ENCODED_RECEIPT_DATA, env: :production)
# {:ok, %ReceiptVerifier.ResponseData{...}}
```

Please view the detailed documentation at [https://hexdocs.pm/receipt_verifier](https://hexdocs.pm/receipt_verifier).

## Changes

See [CHANGELOG.md](CHANGELOG.md)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/linjunpop/receipt_verifier.

## See also

- [ReceiptDecoder](https://github.com/linjunpop/receipt_decoder) - decode the receipt
