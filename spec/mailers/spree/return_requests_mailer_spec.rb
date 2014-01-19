require "spec_helper"

describe Spree::ReturnRequestsMailer do
  describe "submitted" do
    let(:mail) { Spree::ReturnRequestsMailer.submitted }

    it "renders the headers" do
      mail.subject.should eq("Thank you for submitting your return request")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "approved" do
    let(:mail) { Spree::ReturnRequestsMailer.approved }

    it "renders the headers" do
      mail.subject.should eq("Approved")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
