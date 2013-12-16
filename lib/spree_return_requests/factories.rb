FactoryGirl.define do
  factory :spree_return_request, class: "Spree::ReturnRequest" do
    order
    email_address "peewee@herman.com"
  end

  factory :spree_return_request_line_item, class: "Spree::ReturnRequestLineItem" do
    qty 1
  end
end
