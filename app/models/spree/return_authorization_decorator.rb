Spree::ReturnAuthorization.class_eval do

  attr_accessor :being_submitted_by_client
  attr_accessor :return_comments
  attr_accessor :return_quantity
  attr_accessor :return_reason
  attr_accessor :total_returned_qty

  validates :total_returned_qty, numericality: { only_integer: true, greater_than: 0 }, if: :being_submitted_by_client
  validate :line_items_are_valid, if: :being_submitted_by_client
  after_commit :send_authorized_mail, on: :create, if: :being_submitted_by_client

  before_destroy { |record| Spree::LineItem::ReturnInfo.destroy_all "return_authorization_id = #{record.id}" }

  def compute_returned_amount
    inventory_units.to_a.sum(&:price_after_discounts)
  end

  def other_authorized_requests
    order.return_authorizations.where(state: 'authorized')
  end

  def order_token
    order.try(:token)
  end

  def get_return_info_for_variant(variant)
    li = order.find_line_item_by_variant(variant)
    return_info = Spree::LineItem::ReturnInfo.for_rma(self).for_line_item(li).first
    if ! return_info
      return_info = Spree::LineItem::ReturnInfo.new(return_authorization: self, line_item: li)
    end
    return_info
  end

  def contains_an_exchange?
    Spree::LineItem::ReturnInfo.for_rma(self).any? { |return_info| return_info.reason == 'Exchange' }
  end

  def self.cancel_authorized_and_expired
    authorized_and_expired.each { |return_auth| return_auth.cancel! }
  end

  def self.authorized_and_expired
    where(state: 'authorized').where('created_at <= ?', SpreeReturnRequests::Config[:return_request_max_authorized_age_in_days].days.ago)
  end

  private
    def find_line_item_by_variant(variant)
      order.find_line_item_by_variant(variant)
    end

    def line_items_are_valid
      return_quantity.keys.each do |variant_id|
        if return_quantity[variant_id].to_i > 0
          errors.add(:base, Spree.t(:must_choose_a_reason_for_each_returned_item)) unless return_reason[variant_id].present?

          if reasons_which_require_comments.include?(return_reason[variant_id]) && return_comments[variant_id].empty?
            errors.add(:base, Spree.t(:must_enter_comments_for_selected_reasons))
          end
        end
      end
    end

    def reasons_which_require_comments
      ['Other', 'Wrong Item', 'Exchange', 'Defective']
    end

    def send_authorized_mail
      Spree::ReturnAuthorizationMailer.authorized(self).deliver if self.authorized?
    end
end
