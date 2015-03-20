class Spree::ReturnAuthorizationMailer < ActionMailer::Base

  def authorized(return_auth)

    @body = SpreeReturnRequests::Config[:return_request_authorized_body]
    @body.gsub!('%%RETURN_AUTHORIZATION_NUMBER%%', return_auth.number)
    @body.gsub!('%%ORDER_NUMBER%%', return_auth.order.number)

    mail(
      from: SpreeReturnRequests::Config[:return_request_emails_from],
      to: return_auth.order.email,
      subject: SpreeReturnRequests::Config[:return_request_authorized_subject],
    )
  end
end
