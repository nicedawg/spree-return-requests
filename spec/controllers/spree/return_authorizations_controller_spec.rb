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

  describe '#create' do

    before do
      @params = {
        return_authorization: {
          reason: 'Heyya',
        },
        order_id: @order.number,
        use_route: 'spree',
      }
    end

    context 'when the user does not have access to the order' do
      it 'should redirect' do
        post :create, @params

        response.should redirect_to spree.login_path
      end
    end

    context 'when the user is logged in and owns the order' do
      it 'should redirect to search and flash success' do
        controller.stub spree_current_user: @user

        post :create, @params

        response.should redirect_to spree.new_return_request_path
        flash[:success].should match(/created/)
      end
    end

    context 'when the user is anonymous but they have the order token' do
      it 'should redirect to search and flash success' do
        post :create, @params.merge(token: @order.token)

        response.should redirect_to spree.new_return_request_path
        flash[:success].should match(/created/i)
      end
    end

    it 'should not allow an anonymous user if they have an incorrect token' do
      post :create, @params.merge(token: @order.token + 'zzz')

      response.should_not be_success
    end

    context 'when order has no shipped units' do
      it 'should redirect back with a flash message' do
        controller.stub spree_current_user: @user

        order = FactoryGirl.create(:order_ready_to_ship)
        order.user = @user
        order.save!

        post :create, @params.merge(order_id: order.number)

        flash[:error].should match(/shipped/)
      end
    end

    context 'when order is past return window' do
      it 'should redirect back with a flash message' do
        controller.stub spree_current_user: @user
        SpreeReturnRequests::Config[:return_request_max_order_age_in_days] = 10
        @order.completed_at = 11.days.ago
        @order.save!

        post :create, @params

        flash[:error].should match(/return window/i)
      end
    end

    context 'when successful' do

      before do
        controller.stub spree_current_user: @user
        @order.completed_at = 1.day.ago
        @order.save!
      end

      it 'should populate the reason' do
        reason = "I'm returning it because it was predestined to be so."
        @params[:return_authorization][:reason] = reason

        post :create, @params
        @return_authorization = Spree::ReturnAuthorization.last

        @return_authorization.reason.should eq reason
      end
    end
  end
end
