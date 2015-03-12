Spree::ReturnAuthorization.class_eval do

  def compute_returned_amount
    order_level_promo_total = order.adjustments.promotion.sum(:amount)

    total = 0
    inventory_units.each do |iu|
      ratio = order.item_total > 0 ? (iu.line_item.price / order.item_total) : 0
      proportional_amount_of_order_level_promo_total = (ratio * order_level_promo_total).round(2)
      total += iu.line_item.price + iu.line_item.promo_total + proportional_amount_of_order_level_promo_total
    end
    total
  end
end
