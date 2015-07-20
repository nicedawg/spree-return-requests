class Spree::ReturnAuthorizationMailer < Spree::BaseMailer

  def authorized(return_auth)

    @body = SpreeReturnRequests::Config[:return_request_authorized_body]
    @body.gsub!('%%ORDER_NUMBER%%', return_auth.order.number)
    @body.gsub!('%%RETURN_AUTHORIZATION_NUMBER%%', return_auth.number)
    @body.gsub!('%%RETURN_AUTHORIZATION_LABELS_LINK%%', labels_return_authorization_url(return_auth.number, token: return_auth.order.token))

    mail(
      from: SpreeReturnRequests::Config[:return_request_emails_from],
      to: return_auth.order.email,
      subject: SpreeReturnRequests::Config[:return_request_authorized_subject],
    )
  end

  def contains_exchange(return_auth)
    @return_auth = return_auth
    mail(
      from: SpreeReturnRequests::Config[:return_request_emails_from],
      to: SpreeReturnRequests::Config[:return_request_admin_email],
      subject: SpreeReturnRequests::Config[:return_request_exchange_notification_subject],
    )
  end
end
