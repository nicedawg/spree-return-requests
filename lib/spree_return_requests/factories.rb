FactoryGirl.define do
  factory :spree_return_request, class: "Spree::ReturnRequest" do
    order
    email_address "peewee@herman.com"
  end
end
