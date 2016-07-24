class InterFAX::Inbound::Fax < InterFAX::Object
  def image
    client.inbound.image(messageId)
  end

  def reload
    client.inbound.find(messageId)
  end

  def mark status = true
    client.inbound.mark(messageId, read: status)
  end

  def resend email = nil
    client.inbound.resend(messageId, email: email)
  end

  def emails
    client.inbound.emails(messageId)
  end
end
