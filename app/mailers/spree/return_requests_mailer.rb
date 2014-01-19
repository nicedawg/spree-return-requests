class Spree::ReturnRequestsMailer < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.spree.return_requests.submitted.subject
  #
  def submitted(return_request)
    mail to: return_request.email_address, subject: "Thank you for submitting your return request"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.spree.return_requests.submitted_admin.subject
  #
  def submitted_admin(return_request)
    @return_request = return_request
    mail to: SpreeReturnRequests::Config[:return_request_admin_notification_email], subject: "A customer submitted a return request"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.spree.return_requests.approved.subject
  #
  def approved(return_request)
    mail to: return_request.email_address, subject: "Your return request has been approved"
  end
end
