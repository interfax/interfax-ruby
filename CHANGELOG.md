# Changelog

All notable changes to this project will be documented in this file. This project adheres to [Semantic Versioning](http://semver.org/).

## [1.2.0]

Add option to use a custom server host, other than `rest.interfax.net`.

To set a different server to use, provide the `host` parameter on initialization:

```ruby
interfax = InterFAX::Client.new(
  username: '...',
  password: '...',
  host: 'test.domain.com'
)
```

## [1.1.1]

Fix bug in `multipart/mixed` bodies.

Resolve a bug where the `multipart/mixed` boundary and the end of a request body wasn't properly closed.

Upgrading to this version is highly recommended.

## [1.1.0]

Add PDF support when saving files.

## [1.0.1]

Fixes a small bug in cancellations.

## [1.0.0]

Full rebuild using the REST API. First release produced by InterFAX.

[1.2.0]: https://github.com/interfax/interfax-ruby/tree/v1.2.0
[1.1.1]: https://github.com/interfax/interfax-ruby/tree/v1.1.1
[1.1.0]: https://github.com/interfax/interfax-ruby/tree/v1.1.0
[1.0.1]: https://github.com/interfax/interfax-ruby/tree/v1.0.1
[1.0.0]: https://github.com/interfax/interfax-ruby/tree/v1.0.0
