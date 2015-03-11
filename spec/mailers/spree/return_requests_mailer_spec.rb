require "spec_helper"

describe Spree::ReturnRequestsMailer do

  let(:order) do
    order = FactoryGirl.create(:shipped_order)
    order.completed_at = 1.day.ago
    order.save!
    order
  end

  let(:return_request) do
    rr = FactoryGirl.build(:spree_return_request, order: order, email_address: order.email)
    rr.submitted_at = Time.now
    rr.save
    rr
  end

  before :each do
    Spree::Config[:mails_from] = 'from@example.com'
  end

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
    let(:mail) do
      return_request.approve!
      Spree::ReturnRequestsMailer.approved(return_request)
    end

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
