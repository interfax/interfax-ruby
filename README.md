# InterFAX Ruby Gem

[![Gem Version](https://badge.fury.io/rb/interfax.svg)](https://badge.fury.io/rb/interfax) [![Build Status](https://travis-ci.org/cbetta/interfax.svg?branch=master)](https://travis-ci.org/cbetta/interfax)

Send and receive faxes in Ruby with the [InterFAX](https://www.interfax.net/en/dev) REST API.

## Installation

Either install directly or via bundler.

```rb
gem 'interfax'
```

## Getting started

```rb
require 'gyft'

# using parameters
client = InterFAX::Client.new(username: '...', password: '...')

# using environment variables:
# * INTERFAX_USERNAME
# * INTERFAX_PASSWORD
client = InterFAX::Client.new
```

The client provides with direct access to every API call as documented in the developer documentation. For example to send a fax:

```rb
client.outbound.send ...
```

## Usage

## Account Balance

```rb
> client.account.balance
9.86
```

## License

This library is released under the [MIT License](LICENSE).
