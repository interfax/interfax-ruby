# InterFAX Ruby Gem

[Installation](#installation) | [Getting Started](#getting-started) | [Usage](#usage) | [License](#license)

[![Gem Version](https://badge.fury.io/rb/interfax.svg)](https://badge.fury.io/rb/interfax)

Send and receive faxes in Ruby with the [InterFAX](https://www.interfax.net/en/dev) REST API.


## Installation

Either install directly or via bundler.

```ruby
gem 'interfax', github: 'interfax/interfax-ruby', branch: 'rest-client'
```

## Getting started

To send a fax from a pdf file:

```ruby
require 'interfax'
interfax = InterFAX::Client.new(username: 'username', password: 'password')
interfax.deliver(faxNumber: "+11111111112", file: 'folder/fax.pdf')
```

# Usage

[Client](#client) | [Account](#account) | [Outbound](#outbound) | [Inbound](#inbound) | [Helper Classes](#helper-classes)

## Client

The client follows the [12-factor](12factor.net/config) apps principle and can be either set directly or via environment variables.

```ruby
# using parameters
interfax = InterFAX::Client.new(username: '...', password: '...')

# using environment variables:
# * INTERFAX_USERNAME
# * INTERFAX_PASSWORD
interfax = InterFAX::Client.new
```

## Account

### Balance

Determine the remaining faxing credits in your account.

```ruby
interfax.account.balance
=> 9.86
```

**Documentation:** [`GET /accounts/self/ppcards/balance`](https://www.interfax.net/en/dev/rest/reference/3001)

## Outbound

[Send](#send-fax) | [Get list](#get-outbound-fax-list) | [Get completed list](#get-completed-fax-list) | [Get record](#get-outbound-fax-record) | [Get image](#get-outbound-fax-image) | [Cancel fax](#cancel-a-fax) | [Search](#search-fax-list)

### Send fax

`.outbound.deliver(options = {})`

Submit a fax to a single destination number.

There are a few ways to send a fax. One way is to directly provide a file path or url.

```ruby
interfax.outbound.deliver(faxNumber: "+11111111112", file: 'file://fax.pdf')
interfax.outbound.deliver(faxNumber: "+11111111112", file: 'https://s3.aws.com/example/fax.pdf')
```

The returned object is a `InterFAX::Outbound::Fax` with just an `id`. You can use this object to load more information, get the image, or cancel the sending of the fax.

```rb
fax = interfax.outbound.deliver(faxNumber: "+11111111112", file: 'file://fax.pdf')
fax = fax.reload # load more information about this fax
fax.image     # load the image sent to the faxNumber
fax.cancel    # cancel the sending of the fax
```

Alternatively you can create an `InterFAX::File` with binary data and pass this in as well.

```ruby
data = File.open('file://fax.pdf').read
file = InterFAX::File.new(data, mime_type: 'application/pdf')
interfax.outbound.deliver(faxNumber: "+11111111112", file: file)
```

To send multiple files just pass in an array strings and `InterFAX::File` objects.

```rb
interfax.outbound.deliver(faxNumber: "+11111111112", files: ['file://fax.pdf', 'https://s3.aws.com/example/fax.pdf'])
```

Under the hood every path and string is turned into a  [InterFAX::File](#InterFax::File) object. For more information see [the documentation](#InterFax::File) for this class.

**Documentation:** [`POST /outbound/faxes`](https://www.interfax.net/en/dev/rest/reference/2918)

[**Additional options:**](https://www.interfax.net/en/dev/rest/reference/2918) `contact`, `postponeTime`, `retriesToPerform`, `csid`, `pageHeader`, `reference`, `pageSize`, `fitToPage`, `pageOrientation`, `resolution`, `rendering`

**Alias**: `interfax.deliver`

----

### Get outbound fax list

`interfax.outbound.all(options = {})`

Get a list of recent outbound faxes (which does not include batch faxes).

```ruby
interfax.outbound.all
=> [#<InterFAX::Outbound::Fax>, ...]
```

**Documentation:** [`GET /outbound/faxes`](https://www.interfax.net/en/dev/rest/reference/2920)

[**Options:**](https://www.interfax.net/en/dev/rest/reference/2920) `limit`, `lastId`, `sortOrder`, `userId`

----

### Get completed fax list

`interfax.outbound.completed(array_of_ids)`

Get details for a subset of completed faxes from a submitted list. (Submitted id's which have not completed are ignored).

```ruby
interfax.outbound.completed(123, 234)
=> [#<InterFAX::Outbound::Fax>, ...]
```

**Documentation:** [`GET /outbound/faxes/completed`](https://www.interfax.net/en/dev/rest/reference/2972)

----

### Get outbound fax record

`interfax.outbound.find(fax_id)`

Retrieves information regarding a previously-submitted fax, including its current status.

```ruby
interfax.outbound.find(123456)
=> #<InterFAX::Outbound::Fax>
```

**Documentation:** [`GET /outbound/faxes/:id`](https://www.interfax.net/en/dev/rest/reference/2921)

----

### Get oubound fax image

`interfax.outbound.image(fax_id)`

Retrieve the fax image (TIFF file) of a submitted fax.

```ruby
image = interfax.outbound.image(123456)
=> #<InterFAX::Image>
image.data
=> # "....binary data...."
image.save('fax.tiff')
=> # saves image to file
```

**Documentation:** [`GET /outbound/faxes/:id/image`](https://www.interfax.net/en/dev/rest/reference/2941)

----

### Cancel a fax

`interfax.outbound.cancel(fax_id)`

Cancel a fax in progress.

```ruby
interfax.outbound.cancel(123456)
=> #<InterFAX::Outbound::Fax>
```

**Documentation:** [`GET /outbound/faxes/:id/cancel`](https://www.interfax.net/en/dev/rest/reference/2939)

----

### Search fax list

`interfax.outbound.search(options = {})`

Search for outbound faxes.

```ruby
interfax.outbound.search(faxNumber: '+1230002305555')
=> [#<InterFAX::Outbound::Fax>, ...]
```

**Documentation:** [`GET /outbound/search`](https://www.interfax.net/en/dev/rest/reference/2959)

[**Options:**](https://www.interfax.net/en/dev/rest/reference/2959) `ids`, `reference`, `dateFrom`, `dateTo`, `status`, `userId`, `faxNumber`, `limit`, `offset`

## Inbound

[Get list](#get-inbound-fax-list) | [Get record](#get-inbound-fax-record) | [Get image](#get-inbound-fax-image) | [Get emails](#get-forwarding-emails) | [Mark as read](#mark-as-readunread) | [Resend to email](#resend-inbound-fax)

### Get inbound fax list

`interfax.inbound.all(options = {})`

Retrieves a user's list of inbound faxes. (Sort order is always in descending ID).

```ruby
interfax.inbound.all
=> [#<InterFAX::Inbound::Fax>, ...]
```

**Documentation:** [`GET /inbound/faxes`](https://www.interfax.net/en/dev/rest/reference/2935)

[**Options:**](https://www.interfax.net/en/dev/rest/reference/2935) `unreadOnly`, `limit`, `lastId`, `allUsers`

---

### Get inbound fax record

`interfax.inbound.find(fax_id)`

Retrieves a single fax's metadata (receive time, sender number, etc.).

```ruby
interfax.inbound.find(123456)
=> #<InterFAX::Inbound::Fax>
```

**Documentation:** [`GET /inbound/faxes/:id`](https://www.interfax.net/en/dev/rest/reference/2938)

---

### Get inbound fax image

`interfax.inbound.image(fax_id)`

Retrieves a single fax's image.

```ruby
image = interfax.inbound.image(123456)
=> #<InterFAX::Image>
image.data
=> # "....binary data...."
image.save('fax.tiff')
=> # saves image to file
```

**Documentation:** [`GET /inbound/faxes/:id/image`](https://www.interfax.net/en/dev/rest/reference/2937)

---

### Get forwarding emails

`interfax.inbound.emails(fax_id)`

Retrieve the list of email addresses to which a fax was forwarded.

```ruby
interfax.inbound.email(123456)
=> [#<InterFAX::Email>]
```

**Documentation:** [`GET /inbound/faxes/:id/emails`](https://www.interfax.net/en/dev/rest/reference/2930)

---

### Mark as read/unread

`interfax.inbound.mark(fax_id, read: is_read)`

Mark a transaction as read/unread.

```ruby
interfax.inbound.mark(123456, read: true) # mark read
=> true
interfax.inbound.mark(123456, read: false) # mark unread
=> true
```

**Documentation:** [`POST /inbound/faxes/:id/mark`](https://www.interfax.net/en/dev/rest/reference/2936)

### Resend inbound fax

`interfax.inbound.resend(fax_id, email: to_email)`

Resend an inbound fax to a specific email address.

```ruby
# resend to the email(s) to which the fax was previously forwarded
interfax.inbound.resend(123456)
=> true
# resend to a specific address
interfax.inbound.resend(123456, email: 'test@example.com')
=> true
```

---

## Helper Classes

### InterFAX::Outbound::Fax

The `InterFAX::Outbound::Fax` is returned in most Outbound APIs. As a convenience the following methods are available.

```rb
fax = interfax.outbound.find(123)
fax = fax.reload # Loads or reloads object
fax.cancel # Cancels the fax
fax.image # Returns a `InterFAX::Image` for this fax
fax.attributes # Returns a plain hash with all the attributes
```

### InterFAX::Inbound::Fax

The `InterFAX::Inbound::Fax` is returned in some of the Inbound APIs. As a convenience the following methods are available.

```rb
fax = interfax.inbound.find(123)
fax = fax.reload # Loads or reloads object
fax.mark(true) # Marks the fax as read/unread
fax.resend(email) # Resend the fax to a specific email address.
fax.image # Returns a `InterFAX::Image` for this fax
fax.emails # Returns a list of InterFAX::ForwardingEmail objects that the fax was forwarded on to
fax.attributes # Returns a plain hash with all the attributes
```

### InterFAX::Image

A lightweight wrapper around the image data for a sent or received fax. Provides the following convenience methods.

```rb
image = interfax.outbound.image(123)
image.data # Returns the raw binary data for the TIFF image.
image.save('folder/fax.tiff') # Saves the TIFF to the path provided
```

### InterFAX::File

This class is used by `interfax.outbound.deliver` to turn every URL, path and binary data into a uniform format, ready to be sent out to the InterFAX API.

It is most useful for sending binary data to the `.deliver` method.

```rb
# binary data
file = InterFAX::File.new('....binary data.....', mime_type: 'application/pdf')
file.header #=> "Content-Type: application/pdf"
file.body #=> '....binary data.....'

interfax.outbound.deliver(faxNumber: '+1111111111112', file: file)
```

Additionally it can be used to turn a URL or path into a valid object as well, though the `.deliver` method does this conversion automatically.

```rb
# a file by path
file = InterFAX::File.new('foo/bar.pdf')
file.header #=> "Content-Type: application/pdf"
file.body #=> '....binary data.....'

# a file by url
file = InterFAX::File.new('https://foo.com/bar.html')
file.header #=> "Content-Location: https://foo.com/bar.html"
file.body #=> nil
```

### InterFAX::ForwardingEmail

A light wrapper around [the response](https://www.interfax.net/en/dev/rest/reference/2930) received by asking for the forwarded emails for a fax.

```ruby
fax = interfax.inbound.find(123)
email = fax.emails.first
email.emailAddress # An email address to which forwarding of the fax was attempted.
email.messageStatus # 0 = OK; number smaller than zero = in progress; number greater than zero = error.
email.completionTime # Completion timestamp.
```

# License

This library is released under the [MIT License](LICENSE).
