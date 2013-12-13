class Spree::ReturnRequest < ActiveRecord::Base
  belongs_to :order

  validates :order, presence: true
  validates :email_address, presence: true

  attr_accessible :order, :email_address

  before_save :verify_order_and_email_match
  before_save :order_cant_be_too_old_to_return

  def returnable_line_items
    order.line_items
  end

  private

    def verify_order_and_email_match
      raise "Order not found" unless order
      raise "Email doesn't match" unless order.email == self.email_address
    end

    def order_cant_be_too_old_to_return
      max_days = SpreeReturnRequests::Config[:return_request_max_order_age_in_days]
      if self.order.completed_at < max_days.days.ago
        throw "The order must have been placed within the last #{max_days} in order to be returned."
      end
    end
end
