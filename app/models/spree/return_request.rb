class Spree::ReturnRequest < ActiveRecord::Base
  belongs_to :order

  has_many :line_items, class_name: "Spree::ReturnRequestLineItem"

  validates :order, presence: true
  validates :email_address, presence: true

  attr_accessible :order, :email_address

  before_save :verify_order_and_email_match
  before_save :order_cant_be_too_old_to_return

  def returnable_qty(line_item_id)
    returnable_line_items.find(0) { |l| l[:id] == line_item_id }[:qty]
  end

  def returnable_line_items

    returned = line_items_returned

    line_items_returnable = order.line_items.map { |li| { id: li.id, qty: li.quantity } }
    line_items_returnable.each do |l|
      if returned[ l[:id] ]
        l[:qty] -= returned[ l[:id] ]
      end
    end

    line_items_returnable
  end

  private

    def line_items_returned
      returned = {}

      return_requests = Spree::ReturnRequest.where(order_id: order.id)
      return_requests.each do |r|
        r.line_items.each do |l|
          returned[l.line_item_id] = 0 if returned[l.line_item_id].nil?
          returned[l.line_item_id] += l.qty
        end
      end
      returned
    end

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
