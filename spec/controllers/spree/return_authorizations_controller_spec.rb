require 'spec_helper'

describe Spree::ReturnAuthorizationsController do

  before do
    @user = FactoryGirl.create(:user)
    @order = FactoryGirl.create(:shipped_order)
    @order.user = @user
    @order.save!
    @order.update!
  end

  describe '#new' do

    it 'should redirect if the current user does not have access to the order' do
      get :new, order_id: @order.number, use_route: 'spree'

      response.should redirect_to spree.login_path
    end

    it 'should render :new if the user does have access to the order' do
      controller.stub spree_current_user: @user

      get :new, order_id: @order.number, use_route: 'spree'

      response.should be_success
    end

    it 'should allow an anonymous user if they have the proper token' do
      get :new, order_id: @order.number, token: @order.token, use_route: 'spree'

      response.should be_success
    end

    it 'should not allow an anonymous user if they have an incorrect token' do
      get :new, order_id: @order.number, token: @order.token + 'zzz', use_route: 'spree'

      response.should_not be_success
    end

    context 'when order has no shipped units' do
      it 'should redirect back with a flash message' do
        controller.stub spree_current_user: @user

        order = FactoryGirl.create(:order_ready_to_ship)
        order.user = @user
        order.save!

        get :new, order_id: order.number, use_route: 'spree'

        flash[:error].should match(/shipped/)
      end
    end

    context 'when order is past return window' do
      it 'should redirect back with a flash message' do
        controller.stub spree_current_user: @user
        SpreeReturnRequests::Config[:return_request_max_order_age_in_days] = 10
        @order.completed_at = 11.days.ago
        @order.save!

        get :new, order_id: @order.number, use_route: 'spree'

        flash[:error].should match(/return window/i)
      end
    end
  end
end
