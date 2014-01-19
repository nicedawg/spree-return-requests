class Spree::ReturnRequestsConfiguration < Spree::Preferences::Configuration
  preference :return_request_max_order_age_in_days, :integer, default: 90
  preference :return_request_admin_notification_email, :string, default: "spree_admin@example.com"
end
