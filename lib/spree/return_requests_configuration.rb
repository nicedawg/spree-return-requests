class Spree::ReturnRequestsConfiguration < Spree::Preferences::Configuration
  preference :return_request_intro_text, :text, default: 'This text is customizable via the configuration page.'
  preference :return_request_max_order_age_in_days, :integer, default: 90
end
