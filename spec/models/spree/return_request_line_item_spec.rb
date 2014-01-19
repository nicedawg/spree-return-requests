require 'spec_helper'

describe Spree::ReturnRequestLineItem do

  it "has a valid factory" do
    return_request = FactoryGirl.build(:spree_return_request)
    FactoryGirl.build(:spree_return_request_line_item, return_request: return_request).should be_valid
  end

  describe "qty" do
    it "does not allow negative numbers" do
      return_request = FactoryGirl.build(:spree_return_request)
      FactoryGirl.build(:spree_return_request_line_item, return_request: return_request, qty: -1).should_not be_valid
    end
  end
end
