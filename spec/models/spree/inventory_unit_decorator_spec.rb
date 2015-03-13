require 'spec_helper'

describe Spree::InventoryUnit do
  describe '#price_after_discounts' do
    context 'when no discounts on orders' do

      before do
        create_order
        complete_order
        ship_order
        @line_item = @order.line_items.first
        @inventory_unit = @line_item.inventory_units.first
      end

      it 'should be the full price' do
        @inventory_unit.price_after_discounts.should eq 10
      end
    end

    context 'when an order-level discount is present' do

      before do
        create_order_with_order_level_promo
        complete_order
        ship_order
        @line_item = @order.line_items.first
        @inventory_unit = @line_item.inventory_units.first
      end

      it 'should be the full price, minus its portion of the order-level discount' do
        # the first line item was $10, and there were two of them. So each one is 10/190 of subtotal. So each one's portion of the $10 discount is $0.53.
        @inventory_unit.price_after_discounts.should eq BigDecimal.new('9.47')
      end
    end
    context 'when a line-item level discount is present' do

      before do
        create_order_with_line_item_level_promo
        complete_order
        ship_order
        @line_item = @order.line_items.first
        @inventory_unit = @line_item.inventory_units.first
      end

      it 'should be the full price, minus its portion of the line-item discount' do
        # Each $10 item was $2 off, so 8
        @inventory_unit.price_after_discounts.should eq 8
      end
    end
  end
end
