require 'net/https'
require 'json'


module InterFAX
  class Client
    class ServerError < StandardError; end
    class NotFoundError < StandardError; end
    class BadRequestError < StandardError; end
    class UnauthorizedError < StandardError; end

    attr_accessor :username, :password, :http

    DOMAIN = "rest.interfax.net".freeze

    def initialize(options = {})
      self.username = options.fetch(:username) do
        ENV['INTERFAX_USERNAME'] || raise(KeyError, "Missing required argument: username")
      end

      self.password = options.fetch(:password) do
        ENV['INTERFAX_PASSWORD'] || raise(KeyError, "Missing required argument: password")
      end

      self.http = Net::HTTP.new(DOMAIN, Net::HTTP.https_default_port)
      http.use_ssl = true
    end

    def account
      InterFAX::Account.new(self)
    end

    def outbound
      InterFAX::Outbound.new(self)
    end

    def get path, params = {}, valid_keys = {}
      uri = uri_for(path, params, valid_keys)
      message = Net::HTTP::Get.new(uri.request_uri)
      message.basic_auth username, password
      transmit(message)
    end

    private

    def uri_for(path, params = {}, keys = {})
      params = filter(params, keys)
      uri = URI("https://#{DOMAIN}#{path}")
      uri.query = URI.encode_www_form(params)
      uri
    end

    def filter params = {}, keys = {}
      params.delete_if do |key, value|
        !keys.include? key.to_sym
      end
    end

    def transmit(message)
      parse(http.request(message))
    end

    def parse response
      case response
      when Net::HTTPSuccess
        json?(response) ? JSON.parse(response.body) : response.body
      when Net::HTTPNotFound
        raise NotFoundError, "Record not found (404)"
      when Net::HTTPBadRequest
        raise BadRequestError, "Bad request (400)"
      when Net::HTTPUnauthorized
        raise UnauthorizedError, "Access Denied (401)"
      else
        if json?(response)
          raise ServerError, "HTTP #{response.code}: #{JSON.parse(response.body)}"
        else
          raise ServerError, "HTTP #{response.code}: #{response.body}"
        end
      end
    end

    def json?(response)
      content_type = response['Content-Type']
      json_header = content_type && content_type.split(';').first == 'text/json'
      has_body = response.body && response.body.length > 0
      json_header && has_body
    end
  end
end
