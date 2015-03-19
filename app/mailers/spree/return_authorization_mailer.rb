class Spree::ReturnAuthorizationMailer < ActionMailer::Base
  def authorized(return_auth)
    mail
  end
end
