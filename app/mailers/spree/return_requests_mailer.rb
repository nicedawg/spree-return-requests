class Spree::ReturnRequestsMailer < ActionMailer::Base

  def submitted(return_request)
    mail to: return_request.email_address, from: site_owner_email, subject: "Thank you for submitting your return request"
  end

  def submitted_admin(return_request)
    @return_request = return_request
    mail to: site_owner_email, from: site_owner_email, subject: "A customer submitted a return request"
  end

  def approved(return_request)
    @return_request = return_request
    mail to: return_request.email_address, from: site_owner_email, subject: "Your return request has been approved"
  end

  private

    def site_owner_email
      Spree::Config[:mails_from]
    end
end
