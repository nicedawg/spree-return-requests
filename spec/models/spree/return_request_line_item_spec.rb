require 'spec_helper'

describe Spree::ReturnRequestLineItem do

  it "has a valid factory" do
    FactoryGirl.build(:spree_return_request_line_item).should be_valid
  end

  describe "qty" do
    it "does not allow non-positive numbers" do
      FactoryGirl.build(:spree_return_request_line_item, qty: 0).should_not be_valid
    end
  end
end
