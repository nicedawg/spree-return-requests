require 'spec_helper'

describe Spree::ReturnRequest do

  it "has a valid factory" do
    FactoryGirl.build(:spree_return_request, email_address: "test@example.local").should be_valid
  end

  it "requires an order" do
    FactoryGirl.build(:spree_return_request, order_id: nil).should_not be_valid
  end

  it "requires an email address" do
    FactoryGirl.build(:spree_return_request, email_address: nil).should_not be_valid
  end

  describe "upon save" do
    it "requires the email address is associated with the order" do
      order = FactoryGirl.create(:shipped_order)
      return_request = Spree::ReturnRequest.new(order: order, email_address: "notright@spree.com")
      expect { return_request.save! }.to raise_error
    end

    it "requires the order be younger than a configurable number of days" do
      SpreeReturnRequests::Config[:return_request_max_order_age_in_days] = 30
      order = FactoryGirl.create(:shipped_order, completed_at: 31.days.ago)
      return_request = Spree::ReturnRequest.new(order: order, email_address: order.email)
      expect { return_request.save! }.to raise_error
    end
  end

  describe "line items allowed to be returned" do

    context "when no previous returns placed against order" do

      before do
        @order = FactoryGirl.create(:shipped_order)
        @return_request = Spree::ReturnRequest.new(order: @order, email_address: @order.email)
      end

      it "should allow the same line items (and their quantities) as the order" do
        @order.line_items.map { |li| { id: li.id, qty: li.quantity } }.should == @return_request.returnable_line_items.map { |li| { id: li[:id], qty: li[:qty] } }
      end
    end

    context "when one previous return was placed against the order" do

      before do
        @order = FactoryGirl.create(:shipped_order)

        # create a return request for all of the order's first line item
        previous_return_request = Spree::ReturnRequest.create!(order: @order, email_address: @order.email)
        previous_return_request.line_items << Spree::ReturnRequestLineItem.create!(line_item: @order.line_items.first, qty: @order.line_items.first.quantity)
        @line_item_returned = previous_return_request.line_items.first

        # and then start a new return request
        @return_request = Spree::ReturnRequest.new(order: @order, email_address: @order.email)
      end

      it "should consider the one previous return" do
        @return_request.returnable_qty(@line_item_returned.id).should == 0
      end
    end

    context "when two previous returns were placed against the order" do

      before do
        @order = FactoryGirl.create(:shipped_order)

        # create a return request for all of the order's first line item
        @previous_return_request = Spree::ReturnRequest.create!(order: @order, email_address: @order.email)
        line_item = @order.line_items.first
        @previous_return_request.line_items << Spree::ReturnRequestLineItem.create!(line_item: line_item, qty: line_item.quantity)

        # and then create a return request for all of the order's second line item
        @previous_return_request_2 = Spree::ReturnRequest.create!(order: @order, email_address: @order.email)
        line_item = @order.line_items.second
        @previous_return_request_2.line_items << Spree::ReturnRequestLineItem.create!(line_item: line_item, qty: line_item.quantity)

        # and then start a new return request to see what will be considered returnable
        @return_request = Spree::ReturnRequest.new(order: @order, email_address: @order.email)
      end

      it "should consider the two previous returns" do
        # shouldn't be able to return any of the order's first line item
        @return_request.returnable_qty(@previous_return_request.line_items.first.line_item_id).should == 0
        # OR the second line item
        @return_request.returnable_qty(@previous_return_request_2.line_items.first.line_item_id).should == 0
      end
    end
  end
end
