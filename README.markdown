# Interfax/Ruby

This library is a wrapper for the interfax.net fax service. For now,
you can do the following:

* Send HTML faxes
* Query the status of a sent fax
* Retrieve a list of incoming faxes
* Get the image for a sent fax

If you're willing to help, just drop me a line.

## Installation

    gem install interfax

## Usage

### Outgoing Faxes

Create a class, inherit from Interfax::Base and set authentication parameters:

    class OrderFax < Interfax::Base
      self.username = "my_interfax_username"
      self.password = "my_interfax_password"
    end


#### Sending Faxes

Creating a fax:

    fax = OrderFax.new(:html).contains("<h1>test</h1>").subject("test").to("+4923456123456")

It is possible to specify more than one receipent:

    fax = OrderFax.new(:html).contains("<h1>test</h1>").subject("test").to(["+4923456123456","+4943254324312"])

To get a summary before sending, just call summary on it which returns a hash:

    fax.summary

Finally:

    result_id = fax.deliver

#### Getting Sent Faxes

To get all faxes:

    faxes = OrderFax.all
  
You can limit the number of received items with an optional parameter:
    
    faxes = OrderFax.all(10)

To find a specific fax:

    OrderFax.find(123456789)

or get more than one at once:

    OrderFax.find(123456789,234567890)


### Incoming Faxes


#### Getting Incoming Faxes

To get a list of incoming faxes, you can either use the base class:

    Interfax::Incoming.username      = 'my_interfax_username'
    Interfax::Incoming.password      = 'my_interfax_password'
    Interfax::Incoming.limit         = 15    # optional, default 100
    Interfax::Incoming.mark_as_read  = false # optional, default false
    
    # fetch unread incoming faxes
    faxes = Interfax::Incoming.new

If you want you can define your own subclass -- useful for keeping
authentication info handy -- you can do so:

    class IncomingFaxes < Interfax::Incoming
      self.username = 'my_interfax_username'
      self.password = 'my_interfax_password'
    end

    # fetch all incoming faxes
    faxes = Interfax::Incoming.all

There are four methods for fetching incoming faxes:

    all - Fetch all incoming faxes 
    unread - Fetch unread incoming faxes
    account_all - Fetch incoming faxes for all users on your account
    account_unread - Fetch unread incoming faxes for all users on your account

    The account_ methods require that you have admin privileges. For
    more information, see the Interfax API documentation.


#### Getting Incoming Fax Images

The Interfax::Incoming methods described above return an array of
instances of the class you called it on. If you're using the
Interfax::Incoming class you'll get those. If you use a subclass,
we'll instantiate that class and return an array of those.

In either event, call the `#image` method to fetch the PDF/TIF of the
fax as a string, suitable for writing to the filesystem in the normal fashion.

    # Assume you've defined a sublcass as above
    all_faxes = IncomingFaxes.all
    all_faxes[0].image # return the first fax's image


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
