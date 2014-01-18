require 'spec_helper'

describe Spree::ReturnRequestsController do

  render_views

  it "should use Spree::ReturnRequestsController" do
    controller.should be_an_instance_of(Spree::ReturnRequestsController)
  end

  describe "GET index" do
    it "redirects to the 'new' form" do
      get :index, use_route: "spree"
      response.should redirect_to spree.new_return_request_path
    end
  end

  describe "GET new" do
    it "should have great success" do
      get :new, use_route: "spree"
      response.should be_success
    end
  end

  describe "POST create" do

    it "requires a valid order number" do
      post :create, return_request: { order_number: nil, email_address: 'brady.somerville@hitcents.com'}, use_route: "spree"
      response.should render_template :new
      flash[:error].should match(/Order/)
    end

    it "requires a valid email address" do
      order = FactoryGirl.create(:shipped_order)
      post :create, return_request: { order_number: order.number, email_address: 'not-a-valid-email-address'}, use_route: "spree"
      response.should render_template :new
      flash[:error].should match(/Email/)
    end

    context "when the order is not found" do

      before do
        @order = FactoryGirl.create(:shipped_order)
        @order.destroy
      end

      it "returns an error message" do
        post :create, return_request: { order_number: @order.number, email_address: 'not-a-valid-email-address'}, use_route: "spree"
        response.should render_template :new
        flash[:error].should match(/order/)
      end
    end

    context "when the order is found" do

      before do
        @order = FactoryGirl.create(:shipped_order)
      end

      context "when the email address isn't valid for that order" do
        it "returns an error message" do
          post :create, return_request: { order_number: @order.number, email_address: 'brady.somerville@hitcents.com'}, use_route: "spree"
          response.should render_template :new
          flash[:error].should match(/Email/)
        end
      end

      context "when the order is older than a certain number of days" do

        before do
          order_age = SpreeReturnRequests::Config[:return_request_max_order_age_in_days] + 1
          @order.completed_at = order_age.days.ago
          @order.save!
        end

        it "returns an error message" do
          post :create, return_request: { order_number: @order.number, email_address: @order.email}, use_route: "spree"
          response.should render_template :new
          flash[:error].should match(/must have been placed within/)
        end
      end

      context "when everything matches up" do
        it "creates the return request and redirects them to the edit form" do
          post :create, return_request: { order_number: @order.number, email_address: @order.email}, use_route: "spree"
          response.should be_redirect
        end
      end
    end
  end

  describe "GET edit" do

    before do
      @order = FactoryGirl.create(:shipped_order)
      @return_request = Spree::ReturnRequest.create(order: @order, email_address: @order.email)
    end

    context "when the return request is marked as submitted" do

      before do
        @return_request.submitted_at = DateTime.now
        @return_request.save!
      end

      it "redirects the user and explains they can't edit submitted requests" do
        get :edit, id: @return_request.id, use_route: "spree"
        response.should be_redirect
        flash[:error].should match(/can't edit submitted/)
      end
    end
  end

  describe "PUT update" do

    before do
      @order = FactoryGirl.create(:shipped_order)
      @return_request = Spree::ReturnRequest.create(order: @order, email_address: @order.email)
    end

    describe "choosing quantities" do
      it "doesn't let them return more products than they ordered" do
        line_item = @order.line_items.first
        put :update, id: @return_request.id, return_request: { return_request_line_items_attributes: [ line_item_id: line_item.id, qty: line_item.quantity + 1 ] }, use_route: "spree"
        response.should render_template :edit
        flash[:error].should match(/can't return more than you purchased/)
      end
    end

    it "marks the request as submitted" do
      put :update, id: @return_request.id, use_route: "spree"
      @return_request.reload.submitted_at.should_not be_nil
    end

    it "marks the request as 'pending'" do
      put :update, id: @return_request.id, use_route: "spree"
      @return_request.reload.status.should == "pending"
    end

    it "sends the customer an email confirmation of their request"

    context "when the return request is marked as submitted" do

      before do
        @return_request.submitted_at = DateTime.now
        @return_request.save!
      end

      it "redirects the user and explains they can't update submitted requests" do
        put :update, id: @return_request.id, use_route: "spree"
        response.should be_redirect
        flash[:error].should match(/can't update submitted/)
      end
    end
  end
end
