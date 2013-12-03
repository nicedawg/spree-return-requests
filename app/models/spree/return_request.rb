class Spree::ReturnRequest < ActiveRecord::Base
  belongs_to :order

  validates :order, presence: true
  validates :email_address, presence: true

  attr_accessible :order, :email_address

  before_save :verify_order_and_email_match

  private

    def verify_order_and_email_match
      raise "Order not found" unless order
      raise "Email doesn't match" unless order.email == self.email_address
    end
end
