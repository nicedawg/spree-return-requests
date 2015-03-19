Spree::ReturnAuthorization.class_eval do

  attr_accessor :being_submitted_by_client
  attr_accessor :reason_other

  validates :reason, presence: true, if: :being_submitted_by_client
  after_commit :send_authorized_mail, on: :create

  before_validation :set_other_reason

  def compute_returned_amount
    inventory_units.to_a.sum(&:price_after_discounts)
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
