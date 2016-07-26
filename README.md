# InterFAX Ruby Gem

[![Gem Version](https://badge.fury.io/rb/interfax.svg)](https://badge.fury.io/rb/interfax) [![Build Status](https://travis-ci.org/cbetta/interfax.svg?branch=master)](https://travis-ci.org/cbetta/interfax)

Send and receive faxes in Ruby with the [InterFAX](https://www.interfax.net/en/dev) REST API.

## Installation

Either install directly or via bundler.

```ruby
gem 'interfax'
```

## Getting started

```ruby
require 'gyft'

# using parameters
interfax = InterFAX::Client.new(username: '...', password: '...')

# using environment variables:
# * INTERFAX_USERNAME
# * INTERFAX_PASSWORD
interfax = InterFAX::Client.new
```

The client provides with direct access to every API call as documented in the developer documentation. For example to send a fax:

```ruby
interfax.outbound.send ...
```

## Usage

## Account Balance

```ruby
interfax.account.balance
=> 9.86
```

## Sending Faxes

### Get fax list

[`GET /outbound/faxes`](https://www.interfax.net/en/dev/rest/reference/2920)

Get a list of recent outbound faxes (which does not include batch faxes).

```ruby
interfax.outbound.all
=> [#<InterFAX::OutboundFax>, ...]

interfax.outbound.all(limit: 1)
=> [#<InterFAX::OutboundFax>]
```

[Options:](https://www.interfax.net/en/dev/rest/reference/2920) `limit`, `lastId`, `sortOrder`, `userId`

## Get completed fax list

[`GET /outbound/faxes/completed`](https://www.interfax.net/en/dev/rest/reference/2972)

Get details for a subset of completed faxes from a submitted list. (Submitted id's which have not completed are ignored).

```ruby
interfax.outbound.completed([123, 234])
=> [#<InterFAX::OutboundFax>, ...]
```

### Get fax record

[`GET /outbound/faxes/:id`](https://www.interfax.net/en/dev/rest/reference/2921)

Retrieves information regarding a previously-submitted fax, including its current status.

```ruby
interfax.outbound.find(fax_id)
=> #<InterFAX::OutboundFax>
```

### Get fax image

[`GET /outbound/faxes/:id/image`](https://www.interfax.net/en/dev/rest/reference/2941)

Retrieve the fax image (TIFF file) of a submitted fax.

```ruby
interfax.outbound.image(fax_id)
=> #<InterFAX::Image>
```

### Cancel fax

[`GET /outbound/faxes/:id/cancel`](https://www.interfax.net/en/dev/rest/reference/2939)

Cancel a fax in progress.

```ruby
interfax.outbound.cancel(fax_id)
=> #<InterFAX::OutboundFax>
```

### Search fax list

[`GET /outbound/search`](https://www.interfax.net/en/dev/rest/reference/2959)

Search for outbound faxes.

```rb
interfax.outbound.search(fax_number: '+1230002305555')
=> [#<InterFAX::OutboundFax>, ...]
```

[Options:](https://www.interfax.net/en/dev/rest/reference/2959) `ids`, `reference`, `dateFrom`, `dateTo`, `status`, `userId`, `faxNumber`, `limit`, `offset`




## License

This library is released under the [MIT License](LICENSE).
