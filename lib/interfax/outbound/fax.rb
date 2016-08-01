class InterFAX::Outbound::Fax < InterFAX::Object
  def image
    client.outbound.image(id)
  end

  def cancel
    client.outbound.cancel(id)
  end

  def reload
    client.outbound.find(id)
  end
end
