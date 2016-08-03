# InterFAX Ruby Gem

[![Gem Version](https://badge.fury.io/rb/interfax.svg)](https://badge.fury.io/rb/interfax) [![Build Status](https://travis-ci.org/interfax/interfax-ruby.svg?branch=master)](https://travis-ci.org/interfax/interfax-ruby)

[Installation](#installation) | [Getting Started](#getting-started) | [Contributing](#contributing) | [Usage](#usage) | [License](#license)

Send and receive faxes in Ruby with the [InterFAX](https://www.interfax.net/en/dev) REST API.

## Installation

This gem requires 2.1+. You can install install it directly or via bundler.

```ruby
gem 'interfax', '~> 1.0.0'
```

## Getting started

To send a fax from a PDF file:

```ruby
require 'interfax'

interfax = InterFAX::Client.new(username: 'username', password: 'password')
fax = interfax.deliver(faxNumber: "+11111111112", file: 'folder/fax.pdf')
fax = fax.reload # resync with API to get latest status
fax.status # Success if 0. Pending if < 0. Error if > 0
```

# Usage

[Client](#client) | [Account](#account) | [Outbound](#outbound) | [Inbound](#inbound) | [Documents](#documents) | [Helper Classes](#helper-classes)

## Client

The client follows the [12-factor](12factor.net/config) apps principle and can be either set directly or via environment variables.

```ruby
# Initialize using parameters
interfax = InterFAX::Client.new(username: '...', password: '...')

# Alternatice: Initialize using environment variables
# * INTERFAX_USERNAME
# * INTERFAX_PASSWORD
interfax = InterFAX::Client.new
```

All connections are established over HTTPS.

## Account

### Balance

Determine the remaining faxing credits in your account.

```ruby
interfax.account.balance
=> 9.86
```

**More:** [documentation](https://www.interfax.net/en/dev/rest/reference/3001)

## Outbound

[Send](#send-fax) | [Get list](#get-outbound-fax-list) | [Get completed list](#get-completed-fax-list) | [Get record](#get-outbound-fax-record) | [Get image](#get-outbound-fax-image) | [Cancel fax](#cancel-a-fax) | [Search](#search-fax-list)

### Send fax

`.outbound.deliver(options = {})`

Submit a fax to a single destination number.

There are a few ways to send a fax. One way is to directly provide a file path or url.

```ruby
# with a path
interfax.outbound.deliver(faxNumber: "+11111111112", file: 'folder/fax.txt')
# with a URL
interfax.outbound.deliver(faxNumber: "+11111111112", file: 'https://s3.aws.com/example/fax.pdf')
```

InterFAX supports over 20 file types including HTML, PDF, TXT, Word, and many more. For a full list see the [Supported File Types](https://www.interfax.net/en/help/supported_file_types) documentation.

The returned object is a `InterFAX::Outbound::Fax` with just an `id`. You can use this object to load more information, get the image, or cancel the sending of the fax.

```rb
fax = interfax.outbound.deliver(faxNumber: "+11111111112", file: 'file://fax.pdf')
fax = fax.reload # Reload fax, allowing you to inspect the status and more

fax.id        # the ID of the fax that can be used in some of the other API calls
fax.image     # returns an image representing the fax sent to the faxNumber
fax.cancel    # cancel the sending of the fax
```

Alternatively you can create an [`InterFAX::File`](#interfaxfile) with binary data and pass this in as well.

```ruby
data = File.open('file://fax.pdf').read
file = interfax.files.create(data, mime_type: 'application/pdf')
interfax.outbound.deliver(faxNumber: "+11111111112", file: file)
```

To send multiple files just pass in an array strings and [`InterFAX::File`](#interfaxfile) objects.

```rb
interfax.outbound.deliver(faxNumber: "+11111111112", files: ['file://fax.pdf', 'https://s3.aws.com/example/fax.pdf'])
```

Under the hood every path and string is turned into a  [InterFAX::File](#interfaxfile) object. For more information see [the documentation](#interfaxfile) for this class.

**Options:** [`contact`, `postponeTime`, `retriesToPerform`, `csid`, `pageHeader`, `reference`, `pageSize`, `fitToPage`, `pageOrientation`, `resolution`, `rendering`](https://www.interfax.net/en/dev/rest/reference/2918)

**Alias**: `interfax.deliver`

----

### Get outbound fax list

`interfax.outbound.all(options = {})`

Get a list of recent outbound faxes (which does not include batch faxes).

```ruby
interfax.outbound.all
=> [#<InterFAX::Outbound::Fax>, ...]
interfax.outbound.all(limit: 1)
=> [#<InterFAX::Outbound::Fax>]
```

**Options:** [`limit`, `lastId`, `sortOrder`, `userId`](https://www.interfax.net/en/dev/rest/reference/2920)

----

### Get completed fax list

`interfax.outbound.completed(array_of_ids)`

Get details for a subset of completed faxes from a submitted list. (Submitted id's which have not completed are ignored).

```ruby
interfax.outbound.completed(123, 234)
=> [#<InterFAX::Outbound::Fax>, ...]
```

**More:** [documentation](https://www.interfax.net/en/dev/rest/reference/2972)

----

### Get outbound fax record

`interfax.outbound.find(fax_id)`

Retrieves information regarding a previously-submitted fax, including its current status.

```ruby
interfax.outbound.find(123456)
=> #<InterFAX::Outbound::Fax>
```

**More:** [documentation](https://www.interfax.net/en/dev/rest/reference/2921)

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

**More:** [documentation](https://www.interfax.net/en/dev/rest/reference/2941)

----

### Cancel a fax

`interfax.outbound.cancel(fax_id)`

Cancel a fax in progress.

```ruby
interfax.outbound.cancel(123456)
=> #<InterFAX::Outbound::Fax>
```

**More:** [documentation](https://www.interfax.net/en/dev/rest/reference/2939)

----

### Search fax list

`interfax.outbound.search(options = {})`

Search for outbound faxes.

```ruby
interfax.outbound.search(faxNumber: '+1230002305555')
=> [#<InterFAX::Outbound::Fax>, ...]
```

**Options:** [`ids`, `reference`, `dateFrom`, `dateTo`, `status`, `userId`, `faxNumber`, `limit`, `offset`](https://www.interfax.net/en/dev/rest/reference/2959)

## Inbound

[Get list](#get-inbound-fax-list) | [Get record](#get-inbound-fax-record) | [Get image](#get-inbound-fax-image) | [Get emails](#get-forwarding-emails) | [Mark as read](#mark-as-readunread) | [Resend to email](#resend-inbound-fax)

### Get inbound fax list

`interfax.inbound.all(options = {})`

Retrieves a user's list of inbound faxes. (Sort order is always in descending ID).

```ruby
interfax.inbound.all
=> [#<InterFAX::Inbound::Fax>, ...]
interfax.inbound.all(limit: 1)
=> [#<InterFAX::Inbound::Fax>]
```

**Options:** [`unreadOnly`, `limit`, `lastId`, `allUsers`](https://www.interfax.net/en/dev/rest/reference/2935)

---

### Get inbound fax record

`interfax.inbound.find(fax_id)`

Retrieves a single fax's metadata (receive time, sender number, etc.).

```ruby
interfax.inbound.find(123456)
=> #<InterFAX::Inbound::Fax>
```

**More:** [documentation](https://www.interfax.net/en/dev/rest/reference/2938)

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

**More:** [documentation](https://www.interfax.net/en/dev/rest/reference/2937)

---

### Get forwarding emails

`interfax.inbound.emails(fax_id)`

Retrieve the list of email addresses to which a fax was forwarded.

```ruby
interfax.inbound.email(123456)
=> [#<InterFAX::Email>]
```

**More:** [documentation](https://www.interfax.net/en/dev/rest/reference/2930)

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

**More:** [documentation](https://www.interfax.net/en/dev/rest/reference/2936)

---

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

**More:** [documentation](https://www.interfax.net/en/dev/rest/reference/2929)

---

## Documents

[Create](#create-document) | [Upload chunk](#upload-chunk) | [Get list](#get-document-list) | [Status](#get-document-status) | [Cancel](#cancel-document)

Document allow for uploading of large files up to 20MB in 200kb chunks. The [`InterFAX::File`](#interfaxfile) format automatically uses this if needed but a sample implementation would look as followed.

```ruby
file = File.open('test.pdf', 'rb')

document = interfax.documents.create('test.pdf', file.size)

cursor = 0
while !file.eof?
  chunk = file.read(500)
  next_cursor = cursor + chunk.length
  document.upload(cursor, next_cursor-1, chunk)
  cursor = next_cursor
end
```

### Create Documents

`interfax.documents.create(name, size, options = {})`

Create a document upload session, allowing you to upload large files in chunks.

```ruby
interfax.documents.create('large_file.pdf', '231234')
=> #<InterFAX::Document uri="https://rest.interfax.net/outbound/documents/123456">
```

**Options:** [`disposition`, `sharing`](https://www.interfax.net/en/dev/rest/reference/2967)

---

### Upload chunk

`interfax.documents.upload(id, range_start, range_end, chunk)`

Upload a chunk to an existing document upload session.

```ruby
interfax.documents.upload(123456, 0, 999, "....binary-data....")
=> true
```

**More:** [documentation](https://www.interfax.net/en/dev/rest/reference/2966)

---

### Get document list

`interfax.documents.all(options = {})`

Get a list of previous document uploads which are currently available.

```ruby
interfax.documents.all
=> #[#<InterFAX::Document>, ...]
interfax.documents.all(offset: 10)
=> #[#<InterFAX::Document>, ...]
```

**Options:** [`limit`, `offset`](https://www.interfax.net/en/dev/rest/reference/2968)

---

### Get document status

`interfax.documents.find(id)`

Get the current status of a specific document upload.

```ruby
interfax.documents.find(123456)
=> #<InterFAX::Document ... >
```

**More:** [documentation](https://www.interfax.net/en/dev/rest/reference/2965)

---

### Cancel document

`interfax.documents.cancel(id)`

Cancel a document upload and tear down the upload session, or delete a previous upload.

```ruby
interfax.documents.cancel(123456)
=> true
```

**More:** [documentation](https://www.interfax.net/en/dev/rest/reference/2964)

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

This class is used by `interfax.outbound.deliver` and `interfax.files` to turn every URL, path and binary data into a uniform format, ready to be sent out to the InterFAX API.

It is most useful for sending binary data to the `.deliver` method.

```rb
# binary data
file = InterFAX::File.new(interfax, '....binary data.....', mime_type: 'application/pdf')
=> #<InterFAX::File>

# Alternatively
file = interfax.files.create('....binary data.....', mime_type: 'application/pdf')
file.header
=> "Content-Type: application/pdf"
file.body
=> '....binary data.....'

interfax.outbound.deliver(faxNumber: '+1111111111112', file: file)
```

Additionally it can be used to turn a URL or path into a valid object as well, though the `.deliver` method does this conversion automatically.

```rb
# a file by path
file = interfax.files.create('foo/bar.pdf')
file.header #=> "Content-Type: application/pdf"
file.body #=> '....binary data.....'

# a file by url
file = interfax.files.create('https://foo.com/bar.html')
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

### InterFAX::Document

The `InterFAX::Document` is returned in most of the Document APIs. As a convenience the following methods are available.

```ruby
document = interfax.documents.find(123)
document = document.reload # Loads or reloads object
document.upload(0, 999, '.....binary data....' # Maps to the interfax.documents.upload method
document.cancel # Maps to the interfax.documents.upload method
document.id  # Extracts the ID from the URI (the API does not return the ID)
```

## Contributing

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull request** so that we can review your changes

# License

This library is released under the [MIT License](LICENSE).
