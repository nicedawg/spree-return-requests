require 'spec_helper'

describe Spree::Admin::ReturnRequestsSettingsController do

  render_views

  context 'when not signed in' do

    before :each do
      sign_in nil
    end

    describe '#edit' do
      it 'should redirect to login' do
        get :edit, use_route: 'spree'
        response.should redirect_to spree.login_path
      end
    end

    describe '#update' do
      it 'should redirect to login' do
        put :update, use_route: 'spree'
        response.should redirect_to spree.login_path
      end
    end
  end

  context 'when signed in as an admin' do

    before :each do
      user = FactoryGirl.create(:admin_user)
      controller.stub spree_current_user: user
    end

    describe '#edit' do
      it 'should render edit' do
        get :edit, use_route: 'spree'

        response.should render_template :edit
        response.should be_success
      end
    end

    describe '#update' do
      it 'should render' do
        put :update, use_route: 'spree'

        response.should render_template :edit
      end

      it 'should update config settings' do
        new_text = 'This here is the new intro text.'
        new_age = 42

        put :update, {
          return_request_intro_text: new_text,
          return_request_max_order_age_in_days: new_age,
          use_route: 'spree',
        }

        response.should render_template :edit
        SpreeReturnRequests::Config[:return_request_intro_text].should == new_text
        SpreeReturnRequests::Config[:return_request_max_order_age_in_days].should == new_age
      end
    end
  end
end

