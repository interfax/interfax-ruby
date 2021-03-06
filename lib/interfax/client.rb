require 'net/https'
require 'json'


module InterFAX
  class Client
    class ServerError < StandardError; end
    class NotFoundError < StandardError; end
    class BadRequestError < StandardError; end
    class UnauthorizedError < StandardError; end

    attr_accessor :username, :password, :http, :host
    attr_writer :outbound, :inbound, :account, :documents, :files

    HOST = "rest.interfax.net".freeze
    USER_AGENT = "InterFAX Ruby #{InterFAX::VERSION}".freeze

    def initialize(options = {})
      self.username = options.fetch(:username) do
        ENV['INTERFAX_USERNAME'] || raise(KeyError, "Missing required argument: username")
      end

      self.password = options.fetch(:password) do
        ENV['INTERFAX_PASSWORD'] || raise(KeyError, "Missing required argument: password")
      end

      self.host = options.fetch(:host) do
        ENV['INTERFAX_HOST'] || HOST
      end

      self.http = Net::HTTP.new(host, Net::HTTP.https_default_port)
      http.set_debug_output $stdout if options[:debug]
      http.use_ssl = true
    end

    def account
      @account ||= InterFAX::Account.new(self)
    end

    def deliver params = {}
      outbound.deliver(params)
    end

    def outbound
      @outbound ||= InterFAX::Outbound.new(self)
    end

    def inbound
      @inbound ||= InterFAX::Inbound.new(self)
    end

    def documents
      @documents ||= InterFAX::Documents.new(self)
    end

    def files
      @files ||= InterFAX::Files.new(self)
    end

    def get path, params = {}, valid_keys = {}
      uri = uri_for(path, params, valid_keys)
      request = Net::HTTP::Get.new(uri.request_uri)
      transmit(request)
    end

    def post path, params = {}, valid_keys = {}, headers = {}, body = nil
      uri = uri_for(path, params, valid_keys)
      request = Net::HTTP::Post.new(uri.request_uri)
      headers.each do |key, value|
        request[key] = value
      end
      request.body = body if body
      transmit(request)
    end

    def delete path
      uri = uri_for(path)
      request = Net::HTTP::Delete.new(uri.request_uri)
      transmit(request)
    end

    private

    def uri_for(path, params = {}, keys = {})
      params = validate(params, keys)
      uri = URI("https://#{host}#{path}")
      uri.query = URI.encode_www_form(params)
      uri
    end

    def validate params = {}, keys = {}
      params.each do |key, value|
        if !keys.include? key.to_sym
          raise ArgumentError.new("Unexpected argument: #{key} - please make to use camelCase arguments")
        end
      end
      params
    end

    def transmit(request)
      request["User-Agent"] = USER_AGENT
      request.basic_auth username, password
      parse(http.request(request))
    end

    def parse response
      case response
      when Net::HTTPSuccess
        if response['location']
          response['location']
        elsif tiff?(response) || pdf?(response)
          return [response.body, response['Content-Type']]
        elsif json?(response)
          begin
            JSON.parse(response.body)
          rescue JSON::ParserError
            response.body
          end
        else
          response.body
        end
      when Net::HTTPNotFound
        raise NotFoundError, "Record not found: #{response.body}"
      when Net::HTTPBadRequest
        raise BadRequestError, "Bad request (400): #{response.body}"
      when Net::HTTPUnauthorized
        raise UnauthorizedError, "Access Denied (401): #{response.body}"
      else
        if json?(response)
          raise ServerError, "HTTP #{response.code}: #{JSON.parse(response.body)}"
        else
          raise ServerError, "HTTP #{response.code}: #{response.body}"
        end
      end
    end

    def pdf?(response)
      type?(response, 'application/pdf')
    end

    def tiff?(response)
      type?(response, 'image/tiff')
    end

    def json?(response)
      type?(response, 'text/json')
    end

    def type?(response, mime_type)
      content_type = response['Content-Type']
      correct_header = content_type && content_type.split(';').first == mime_type
      has_body = response.body && response.body.length > 0
      correct_header && has_body
    end
  end
end
