class Spree::ReturnRequest < ActiveRecord::Base

  scope :for_order_id, ->(order_id) { where("order_id = ?", order_id) }
  scope :submitted, where("submitted_at IS NOT NULL")
  scope :by_status, ->(status) { where(status: status) }

  belongs_to :order
  belongs_to :return_authorization

  has_many :return_request_line_items, class_name: "Spree::ReturnRequestLineItem"

  attr_accessible :order, :order_id, :order_number, :email_address, :return_request_line_items_attributes, :ready_to_submit, :reason
  attr_accessor :order_number, :ready_to_submit

  accepts_nested_attributes_for :return_request_line_items

  before_save :find_order_by_number_if_necessary
  before_save :verify_order_is_present
  before_save :verify_order_and_email_match
  before_save :order_cant_be_too_old_to_return
  before_save :mark_as_submitted_if_ready_to_submit

  validates :email_address, presence: true

  def line_items
    self.return_request_line_items
  end

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

  def dump
    puts "order_id: #{order_id}\t email_address: #{email_address}"
    line_items.each do |li|
      puts "\t#{li.dump}"
    end
  end

  def approve!
    self.status = "approved"
    self.return_authorization = build_return_authorization
    self.save!
  end

  private

    def build_return_authorization
      ra = Spree::ReturnAuthorization.new
      ra.order = self.order
      ra.reason = self.reason

      ra.amount = 0
      self.line_items.each do |rr_li|
        if rr_li.qty > 0
          ra.add_variant rr_li.line_item.variant_id, rr_li.qty if rr_li.qty > 0
          ra.amount += rr_li.line_item.amount
        end
      end

      ra.save!
      ra
    end

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

    def find_order_by_number_if_necessary
      if order_number && ! order
        self.order = Spree::Order.where(number: order_number).first
        unless self.order
          errors.add(:base, "Can't find order with that number.")
          return false
        end
      end
    end

    def verify_order_is_present
      unless self.order
        errors.add(:base, "Order not found.")
        return false
      end
    end

    def verify_order_and_email_match
      unless order && order.email == self.email_address
        errors.add(:base, "Email doesn't match")
        return false
      end
    end

    def order_cant_be_too_old_to_return
      max_days = SpreeReturnRequests::Config[:return_request_max_order_age_in_days]
      if self.order.completed_at < max_days.days.ago
        errors.add(:base, "The order must have been placed within the last #{max_days} in order to be returned.")
        return false
      end
    end

    def mark_as_submitted_if_ready_to_submit
      if self.ready_to_submit && self.ready_to_submit != "0"
        self.submitted_at = DateTime.now
        self.status = "pending"
      end
    end
end
