class InterFAX::File
  attr_accessor :header, :body, :client, :chunk_size

  def initialize client, location, options = {}
    self.client = client
    self.chunk_size = options[:chunk_size] || 1024*1024

    if options[:mime_type]
      initialize_binary(location, options[:mime_type])
    elsif location.start_with?('http://') || location.start_with?('https://')
      initialize_url(location)
    else
      initialize_path(location)
    end
  end

  def initialize_binary(data, mime_type)
    return initialize_document(data, mime_type) if data.length > chunk_size
    self.header = "Content-Type: #{mime_type}"
    self.body = data
  end

  def initialize_url(url)
    self.header = "Content-Location: #{url}"
    self.body = nil
  end

  def initialize_path(path)
    file = File.open(path)
    mime_type = MimeMagic.by_magic(file) || MimeMagic.by_path(file)
    data = File.open(path, 'rb').read

    initialize_binary(data, mime_type)
  end

  def initialize_document(data, mime_type)
    document = create_document(data, mime_type)
    upload(document, data)
    initialize_url(document.uri)
  end

  def upload document, data
    cursor = 0
    data.bytes.each_slice(chunk_size) do |slice|
      chunk = slice.pack("C*")
      next_cursor = cursor + chunk.length
      document.upload(cursor, next_cursor - 1, chunk)
      cursor = next_cursor
    end
  end

  def create_document data, mime_type
    extension = MimeMagic::EXTENSIONS.select {|k,v| v == mime_type.to_s}.keys.first
    client.documents.create("upload-#{Time.now.to_i}.#{extension}", data.length)
  end
end
