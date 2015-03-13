Spree::ReturnAuthorization.class_eval do

  def compute_returned_amount
    inventory_units.to_a.sum(&:price_after_discounts)
  end
end
