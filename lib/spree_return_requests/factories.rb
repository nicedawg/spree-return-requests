FactoryGirl.define do
  factory :spree_return_request, class: "Spree::ReturnRequest" do
    association :order, factory: :shipped_order
    email_address { order.email }
  end

  factory :spree_return_request_line_item, class: "Spree::ReturnRequestLineItem" do
    association :return_request, factory: :spree_return_request
    line_item { return_request.order.line_items.first }
    qty 1
  end
end
