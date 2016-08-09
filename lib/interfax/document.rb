class InterFAX::Document < InterFAX::Object
  def upload range_start, range_end, chunk
    client.documents.upload(id, range_start, range_end, chunk)
  end

  def cancel
    client.documents.cancel(id)
  end

  def reload
    client.documents.find(id)
  end

  def id
    uri.split("/").last
  end
end
