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
        create_order_with_order_level_promo
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
        create_order_with_line_item_level_promo
        complete_order
        ship_order
        return_order
      end

      it 'should be the full amount of the returned inventory units, minus their portion of the line-item discount' do
        # returning 1 x $10 item, but it was $2 off, so total of $8
        # returning 2 x $30 item, but each was $28,   so total of $56
        # so total being returned is $64
        @return_authorization.compute_returned_amount.should eq BigDecimal.new('64')
      end
    end
  end
end
