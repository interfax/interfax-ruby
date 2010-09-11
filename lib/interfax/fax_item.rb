module Interfax

  class FaxItem < Struct.new(:id, :submit_time, :postpone_time, :receiver_number, :duration, :remote_csid, :sent_pages, :status, :subject, :submitted_pages)
    def pages
      "#{sent_pages}/#{submitted_pages}"
    end
    
    def ok
      (status.to_i >= 0) ? true : false
    end
  end

end