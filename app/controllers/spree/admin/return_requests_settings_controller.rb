module Spree
  module Admin
    class ReturnRequestsSettingsController < Admin::BaseController
      def edit
        render :edit
      end

      def update
        simple_settings = [
          :return_request_authorized_body,
          :return_request_authorized_subject,
          :return_request_emails_from,
          :return_request_intro_text,
          :return_request_max_order_age_in_days,
          :return_request_past_return_window_text,
          :return_request_success_text
        ]

        simple_settings.each do |setting|
           SpreeReturnRequests::Config[setting] = params[setting]
         end

         if params[:return_request_reasons].present?
           SpreeReturnRequests::Config[:return_request_reasons] = params[:return_request_reasons].split("\n").reject { |r| r.blank? }.join("\n")
         end

         flash[:success] = Spree.t(:successfully_updated, :resource => Spree.t(:return_requests_settings))
         render :edit
      end
    end
  end
end
