module Spree
  module Admin
    class ReturnRequestsSettingsController < Admin::BaseController
      def edit
        render :edit
      end

      def update
         [:return_request_intro_text, :return_request_max_order_age_in_days].each do |setting|
           SpreeReturnRequests::Config[setting] = params[setting]
         end
         flash[:success] = Spree.t(:successfully_updated, :resource => Spree.t(:return_requests_settings))
         render :edit
      end
    end
  end
end
