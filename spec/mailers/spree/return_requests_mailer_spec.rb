require "spec_helper"

describe Spree::ReturnRequestsMailer do

  let(:order) { FactoryGirl.build(:shipped_order) }
  let(:return_request) { FactoryGirl.build(:spree_return_request, order: order, email_address: "test@example.com") }

  describe "submitted" do
    let(:mail) { Spree::ReturnRequestsMailer.submitted(return_request) }

    it "renders the headers" do
      mail.subject.should eq("Thank you for submitting your return request")
      mail.to.should eq([return_request.email_address])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Thank you for submitting")
    end
  end

  describe "approved" do
    let(:mail) { Spree::ReturnRequestsMailer.approved(return_request) }

    it "renders the headers" do
      mail.subject.should eq("Your return request has been approved")
      mail.to.should eq([return_request.email_address])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Your return request has been approved")
    end
  end

end
