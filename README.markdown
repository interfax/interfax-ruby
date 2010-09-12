# Interfax/Ruby

This library is a wrapper for the interfax.net fax service. Until now only sending of html faxes and status 
querying is supported.

If you're willing to help, just drop me a line.

## Example

Create a class, inherit from Interfax::Base and set authentication parameters:

    class OrderFax < Interfax::Base
      self.username = "my_interfax_username"
      self.password = "my_interfax_password"
    end


### Sending

Creating a fax:

    fax = OrderFax.new(:html).contains("<h1>test</h1>").subject("test").to("+4923456123456")

It is possible to specify more than one receipent:

    fax = OrderFax.new(:html).contains("<h1>test</h1>").subject("test").to(["+4923456123456","+4943254324312"])

To get a summary before sending, just call summary on it which returns a hash:

    fax.summary

Finally:

    result_id = fax.deliver

### Querying

To get all faxes:

    faxes = OrderFax.all
  
You can limit the number of received items with an optional parameter:
    
    faxes = OrderFax.all(10)

To find a specific fax:

    OrderFax.find(123456789)

or get more than one at once:

    OrderFax.find(123456789,234567890)

## Interfax API documentation

http://www.interfax.net/en/dev/webservice/reference/methods

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Sascha Brink. See LICENSE for details.
