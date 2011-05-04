require 'soap/wsdlDriver'
require 'Base64'

module Interfax

  # = Interfax::Incoming
  #
  # Allows interaction with the Interfax Inbound API, documented at:
  # http://www.interfax.net/en/dev/webservice/reference_in
  #
  # == Retrieving incoming faxes
  #
  # Set the +username+ and +password+ variables appropriately, and
  # then call one of the query methods, which are described in further
  # detail below.
  # 
  #   Interfax::Incoming.username = 'my_interfax_username'
  #   Interfax::Incoming.password = 'my_interfax_password'
  #   faxes = Interfax::Incoming.unread
  #
  # You can extend Interfax::Incoming, and the query methdos will
  # return instances of your subclass. This is useful for extending
  # functionality, or consolidating your configuration in one place.
  #
  #   class InboundFax < Interfax::Incoming
  #     self.username = 'my_interfax_username'
  #     self.password = 'my_interfax_password'
  #
  #     def write_image_to_file
  #       File.open("/path/to/file", 'w') { |f| f.write(image)
  #     end
  #   end
  #
  #   faxes = InboundFax.all # this is an array of InboundFax objects
  #   faxes.map(&:write_image_to_file)
  #
  # == Methods
  #
  # The methods available for fetching or querying inbound faxes are:
  #
  # * +#all+ - Retrieves all inbound faxes, up to +limit+.
  # * +#unread+ - Retrieves any unread faxes, up to +limit+.
  # * +#account_all+ - Retrieves inbound faxes for all users on your
  #   account, up to +limit+. Requires an administrator account.
  # * +#account_unread+ - Same as above, but fetches only unread
  #   faxes. Also requires an administrator account.
  #
  # As seen above, these methods return instances of the class they're
  # called on, which makes it easy to extend your objects for custom
  # functionality. 
  #
  # == Configuration
  #
  # We require that the following two configuration variables be set
  # at the class level, as seen in the examples above.
  #
  # * +username+ - [required] Your interfax username.
  # * +password+ - [requierd] Your interfax password.
  #
  # We also support a few other configuration methods, which are
  # explained further in Interfax's API documentation.
  #
  # * +limit+ - [1..100, default 100] The maximum number of faxes to return.
  # * +mark_as_read+ - [boolean, default false] Whether or not to mark
  #   retrieved faxes as sent.
  #
  # These options are also accepted as options when requesting faxes:
  #
  #   # Assume username/password already set
  #   Interfax::Incoming.all(:limit => 10, :mark_as_read => true)
  #
  # Options supplied this way will temporarily override any options
  # set on the class.
  
  class Incoming
    
    class << self
      attr_accessor :username, :password, :mark_as_read, :limit #:nodoc:

      def soap_client #:nodoc:
        SOAP::WSDLDriverFactory.
          new("https://ws.interfax.net/inbound.asmx?WSDL").
          create_rpc_driver
      end
      
      def query(type, opts = {}) #:nodoc:
        result = self.soap_client.GetList(:Username => self.username,
                  :Password => self.password,
                  :MaxItems => opts[:limit] || self.limit || 100,
                  :MarkAsRead => opts[:mark_as_read] || self.mark_as_read || false,
                  :LType => type
                  )
        
        return [] if result.nil? || !defined?(result.objMessageItem)
        [*result.objMessageItem.messageItem].map do |fax|
          self.new(fax)
        end
      end

      # Returns all inbound messages for your user up to the +limit+
      # option. Optionally marks the faxes as read.
      #
      # ==== Options (as hash)
      #
      # Both of these will default to whatever values you've set for
      # the class, or 100 (limit) or false (mark_as_read) if you haven't.
      # * +:limit+ - Maximum number of faxes to return.
      # * +:mark_as_read+: Mark fetched faxes as read.
     
      def all(opts = {})
        query('AllMessages', opts)
      end
      
      # Returns any unread messages for your user up to the +limit+
      # option. Optionally marks the faxes as read.
      #
      # ==== Options (as hash)
      #
      # Both of these will default to whatever values you've set for
      # the class, or 100 (limit) or false (mark_as_read) if you haven't.
      # * +:limit+ - Maximum number of faxes to return.
      # * +:mark_as_read+: Mark fetched faxes as read.
      
      def unread(opts = {})
        query('NewMessages', opts)
      end
      
      # Returns all messages for all users on your account, up
      # to the +limit+ option. Optionally marks the faxes as
      # read. Requires your user be an administrator for your account.
      #
      # ==== Options (as hash)
      #
      # Both of these will default to whatever values you've set for
      # the class, or 100 (limit) or false (mark_as_read) if you haven't.
      # * +:limit+ - Maximum number of faxes to return.
      # * +:mark_as_read+: Mark fetched faxes as read.
      
      def account_all(opts = {})
        query('AccountAllMessages', opts)
      end

      # Returns any unread messages for all users on your account, up
      # to the +limit+ option. Optionally marks the faxes as
      # read. Requires your user be an administrator for your account.
      #
      # ==== Options (as hash)
      #
      # Both of these will default to whatever values you've set for
      # the class, or 100 (limit) or false (mark_as_read) if you haven't.
      # * +:limit+ - Maximum number of faxes to return.
      # * +:mark_as_read+: Mark fetched faxes as read.

      def account_unread(opts = {})
        query('AccountNewMessages', opts)
      end
      
    end

    # class methods

    attr_accessor :username, :password, :mark_as_read, :chunk_size, :message_id, :message_size, :image,
      :interfax_number, :remote_csid, :message_status, :pages, :message_type, :receive_time, :caller_id, 
      :duration
    
    # Normally this is instantied for you as a result of calling one of the
    # querying class methods. If you want to instantiate an object yourself,
    # you can pass it the results of the GetList API call, or any object that
    # looks like it.
    # See: http://www.interfax.net/en/dev/webservice/reference/getlist
    def initialize(params = nil)
      @username = self.class.username
      @password = self.class.password
      @mark_as_read = self.class.mark_as_read || false
      @chunk_size = 100000

      unless params.nil?
        @message_id = params.messageID
        @message_size = params.messageSize.to_i
        @interfax_number = params.phoneNumber
        @remote_csid = params.remoteCSID
        @message_status = params.messageStatus
        @pages = params.pages
        @message_type = params.messageType
        @receive_time = params.receiveTime
        @caller_id = params.callerID
        @duration = params.messageRecordingDuration
      end
      
      @image = nil
    end

    # Retrieves the image from the Interfax Inbound API, as a
    # string. Suitable for writing to a file or streaming to a client.
    def image
      @image || fetch_image
    end
    
    def fetch_image #:nodoc:
      @image = ""
      downloaded_size = 0
      while downloaded_size < @message_size
        result = self.class.soap_client.GetImageChunk(:Username => @username,
                                                :Password => @password,
                                                :MessageID => @message_id,
                                                :MarkAsRead => @mark_as_read,
                                                :ChunkSize => @chunk_size,
                                                :From => downloaded_size)

        # TODO: Make this throw a nicer exception on failure
        if defined?(result.image)
          @image << Base64.decode64(result.image)
        end
        downloaded_size += @chunk_size

      end
      
      @image
    end

  end

end
