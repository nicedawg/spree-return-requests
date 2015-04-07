Spree::ReturnAuthorization.class_eval do

  attr_accessor :being_submitted_by_client
  attr_accessor :reason_other
  attr_accessor :total_returned_qty

  validates :reason, presence: true, if: :being_submitted_by_client
  validates :total_returned_qty, numericality: { only_integer: true, greater_than: 0 }, if: :being_submitted_by_client
  after_commit :send_authorized_mail, on: :create

  before_validation :set_other_reason

  def compute_returned_amount
    inventory_units.to_a.sum(&:price_after_discounts)
  end

  def other_authorized_requests
    order.return_authorizations.where(state: 'authorized')
  end

  def order_token
    order.try(:token)
  end

  def self.cancel_authorized_and_expired
    authorized_and_expired.each { |return_auth| return_auth.cancel! }
  end

  def self.authorized_and_expired
    where(state: 'authorized').where('created_at <= ?', SpreeReturnRequests::Config[:return_request_max_authorized_age_in_days].days.ago)
  end

  private
    def set_other_reason
      return unless new_record?
      if reason == "Other" && reason_other.present?
        self.reason = "Other: " + reason_other
      end
    end

    def send_authorized_mail
      Spree::ReturnAuthorizationMailer.authorized(self).deliver if self.authorized?
    end
end
