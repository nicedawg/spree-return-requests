Spree::LineItem.class_eval do
  has_many :returns, class_name: 'Spree::LineItem::ReturnInfo', dependent: :destroy
  delegate :return_reason, :return_comments, to: :return_info, allow_nil: true
end
