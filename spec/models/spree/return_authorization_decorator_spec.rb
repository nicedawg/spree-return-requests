require 'spec_helper'

describe Spree::ReturnAuthorization do

  describe '#compute_returned_amount' do

    context 'when no discounts on orders' do

      before do
        create_order
        complete_order
        ship_order
        return_order
      end

      it 'should be the full amount of the returned inventory units' do
        # we are returning 1 x $10 item  and 2 x $30 item, so total should be $70
        @return_authorization.compute_returned_amount.should eq BigDecimal.new('70')
      end
    end

    context 'when an order-level discount is present' do

      before do
        create_order

        promo = FactoryGirl.create(:promotion, :with_order_adjustment, code: "test123")
        @order.coupon_code = promo.code
        promo_handler = Spree::PromotionHandler::Coupon.new(@order)
        promo_handler.apply
        @order.update!
        @order.reload

        complete_order
        ship_order
        return_order
      end

      it 'should be the full amount of the returned inventory units, minus their portion of the order-level discount' do
        # promo took $10 off order.of $190 dollars
        # returning 1 x $10. its proportional order level promo amount is $0.53. So worth $9.47
        # returning 2 x $30. its proportional order level promo amount is $3.16. so worth $56.84
        # so total should be $66.31.
        @return_authorization.compute_returned_amount.should eq BigDecimal.new('66.31')
      end
    end

    context 'when a line-item level discount is present' do

      before do
        create_order

        promo = FactoryGirl.create(:promotion, :with_line_item_adjustment, code: "test123")
        @order.coupon_code = promo.code
        promo_handler = Spree::PromotionHandler::Coupon.new(@order)
        promo_handler.apply
        @order.update!
        @order.reload

        complete_order
        ship_order
        return_order
      end

      it 'should be the full amount of the returned inventory units, minus their portion of the line-item discount' do
        # returning 1 x $10 item, but it was $10 off, so total of $0
        # returning 2 x $30 item, but each was $20,   so total of $40
        # so total being returned is $40
        @return_authorization.compute_returned_amount.should eq BigDecimal.new('40')
      end
    end
  end

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
