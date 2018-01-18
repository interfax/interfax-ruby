class InterFAX::Outbound::Delivery
  attr_accessor :client, :params, :files, :fax_number

  VALID_KEYS = [:faxNumber, :contact, :postponeTime, :retriesToPerform, :csid, :pageHeader, :reference, :replyAddress, :pageSize, :fitToPage, :pageOrientation, :resolution, :rendering]
  BOUNDARY = "43e578690a6d14bf1d776cd55e7d7e29"
  HEADERS = {
    "Content-Type" => "multipart/mixed; boundary=#{BOUNDARY}"
  }.freeze

  def initialize client
    self.client = client
  end

  def deliver params
    params, files = validate_params(params)

    file_objects = generate_file_objects(files)
    body = body_for(file_objects)

    result = client.post('/outbound/faxes', params, VALID_KEYS, HEADERS, body)
    InterFAX::Outbound::Fax.new(client: client, id: result.split('/').last)
  end

  private

  def validate_params params
    self.fax_number = params[:faxNumber] || raise(ArgumentError.new('Missing argument: faxNumber'))
    files = [params[:file] || params[:files] || raise(ArgumentError.new('Missing argument: file or files'))].flatten

    params.delete(:fax_number)
    params.delete(:file)
    params.delete(:files)

    [params, files]
  end

  def generate_file_objects files
    files.map do |file|
      if file.kind_of?(String)
        InterFAX::File.new(client, file)
      elsif file.kind_of?(InterFAX::File)
        file
      end
    end
  end

  def body_for(files)
    files.map do |file|
      "--#{BOUNDARY}\r\n#{file.header}\r\n\r\n#{file.body}\r\n"
    end.join + "--#{BOUNDARY}--\r\n"
  end
end
