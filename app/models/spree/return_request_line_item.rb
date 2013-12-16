class Spree::ReturnRequestLineItem < ActiveRecord::Base
  belongs_to :spree_return_request
  belongs_to :line_item

  validates :qty, numericality: {
    only_integer: true,
    greater_than: 0,
    message: Spree.t('validation.must_be_int')
  }
end
