module Spree
  class LineItem
    class ReturnInfo < ActiveRecord::Base
      belongs_to :return_authorization, class_name: 'Spree::ReturnAuthorization'
      belongs_to :line_item, class_name: 'Spree::LineItem'

      scope :for_rma, -> (rma) { where(return_authorization: rma) }
      scope :for_line_item, -> (line_item) { where(line_item: line_item) }
    end
  end
end
