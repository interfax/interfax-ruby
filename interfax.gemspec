require File.expand_path('lib/interfax/version', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name        = 'interfax'
  s.version     =  InterFAX::VERSION
  s.summary     = "Send and receive faxes with InterFAX"
  s.description = "A wrapper around the InterFAX REST API for sending and receiving faxes."
  s.authors     = ["InterFAX", "Cristiano Betta"]
  s.email       = ['developer@interfax.net', 'cbetta@gmail.com']
  s.files       = Dir.glob('{lib,spec}/**/*') + %w(LICENSE README.md interfax.gemspec)
  s.homepage    = 'https://github.com/interfax/interfax-ruby'
  s.license     = 'MIT'
  s.require_path = 'lib'

  s.add_development_dependency('rake')
  s.add_development_dependency('webmock')
  s.add_development_dependency('minitest')
end
