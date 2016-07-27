class InterFAX::Outbound::Fax < InterFAX::Object
  def image
    client.outbound.image(id)
  end

  def cancel
    client.outbound.cancel(id)
  end
end
