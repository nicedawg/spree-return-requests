module OrderHelpers
  def create_order
    @order = FactoryGirl.create(:order)
    FactoryGirl.create(:line_item, order: @order, quantity: 2, price: BigDecimal.new('10.00'))
    FactoryGirl.create(:line_item, order: @order, quantity: 4, price: BigDecimal.new('20.00'))
    FactoryGirl.create(:line_item, order: @order, quantity: 3, price: BigDecimal.new('30.00'))
    @order.line_items.reload

    @order.ship_address = FactoryGirl.create(:ship_address)

    FactoryGirl.create(:shipment, order: @order)
    @order.shipments.reload
    @order.update!
  end

  def create_order_with_order_level_promo
    create_order

    promo = FactoryGirl.create(:promotion, :with_order_adjustment, code: "test123")
    @order.coupon_code = promo.code
    promo_handler = Spree::PromotionHandler::Coupon.new(@order)
    promo_handler.apply
    @order.update!
    @order.reload
  end

  def create_order_with_line_item_level_promo
    create_order

    promo = FactoryGirl.create(:promotion, :with_line_item_adjustment, code: "test123", adjustment_rate: 2)
    @order.coupon_code = promo.code
    promo_handler = Spree::PromotionHandler::Coupon.new(@order)
    promo_handler.apply
    @order.update!
    @order.reload
  end

  def complete_order
    @order.state = 'complete'
    @order.refresh_shipment_rates
    @order.update_column(:completed_at, Time.now)
    FactoryGirl.create(:payment, amount: @order.total, order: @order, state: 'completed')
    @order.payment_state = 'paid'
    @order.shipment_state = 'ready'
  end

  def ship_order
    @order.shipments.each do |shipment|
      shipment.inventory_units.each { |u| u.update_column('state', 'shipped') }
      shipment.update_column(:state, 'shipped')
    end
    @order.reload
  end

  def return_order
    @return_authorization = FactoryGirl.create(:return_authorization, order: @order)
    @return_authorization.add_variant(@order.line_items.first.variant_id, 1)
    @return_authorization.add_variant(@order.line_items.last.variant_id, 2)
  end
end
