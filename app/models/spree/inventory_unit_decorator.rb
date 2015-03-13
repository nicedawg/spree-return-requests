Spree::InventoryUnit.class_eval do

  def price_after_discounts
     (unit_price + proportional_order_level_amount + unit_promo_amount).round(2)
  end

  private
    def unit_price
      line_item.price
    end

    def proportional_order_level_amount
      order = line_item.order
      order_level_promo_total = order.adjustments.promotion.sum(:amount)
      ratio = order.item_total > 0 ? (line_item.price / order.item_total) : 0
      (ratio * order_level_promo_total).round(2)
    end

    def unit_promo_amount
      line_item.promo_total / line_item.quantity rescue 0
    end
end
