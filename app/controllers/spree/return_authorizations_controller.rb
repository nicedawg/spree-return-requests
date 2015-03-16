module Spree
  class ReturnAuthorizationsController < Spree::StoreController

    before_filter :check_authorization, only: [:new, :create]
    before_filter :ensure_order_has_shipped_units, only: [:new, :create]
    before_filter :ensure_order_is_within_return_window, only: [:new, :create]

    def new
      @return_authorization = Spree::ReturnAuthorization.new(order: @order, being_submitted_by_client: true)
    end

    def create
      @return_authorization = Spree::ReturnAuthorization.new(permitted_params, being_submitted_by_client: true)
      @return_authorization.order = @order

      if @return_authorization.save
        (params[:return_quantity] || []).each { |variant_id, qty| @return_authorization.add_variant(variant_id.to_i, qty.to_i) }
        @return_authorization.amount = @return_authorization.compute_returned_amount
        @return_authorization.save!

        redirect_to spree.new_return_request_path, flash: { success: Spree.t(:return_requests_return_authorization_succesfully_created) }
        return
      else
        render :new
      end
    end

    def search
      @errors = []

      if params.include?(:order)
        @errors << "Order Number is required." unless params[:order][:order_number].present?
        @errors << "Email Address is required." unless params[:order][:email_address].present?

        if params[:order][:order_number].present? && params[:order][:email_address].present?
          order = Spree::Order.where(number: params[:order][:order_number], email: params[:order][:email_address]).first

          if order
            redirect_to(new_order_return_authorization_path(order)) && return
          else
            @errors << "Order not found."
          end
        end
      end

    end

    private

      def check_authorization
        session[:access_token] = params[:token] if params[:token]
        begin
          @order = Spree::Order.find_by_number(params[:order_id])
          authorize! :read, @order, session[:access_token]
        rescue
          redirect_to(orders_return_authorizations_search_path) && return
        end
      end

      def ensure_order_has_shipped_units
        unless @order.shipped?
          redirect_to orders_return_authorizations_search_path, flash: { error: Spree.t(:return_requests_order_must_be_shipped) }
          return
        end
      end

      def ensure_order_is_within_return_window
        if @order.completed_at < SpreeReturnRequests::Config[:return_request_max_order_age_in_days].days.ago
          redirect_to orders_return_authorizations_search_path, flash: { error: Spree.t(:return_requests_order_not_within_return_window) }
          return
        end
      end

      def permitted_params
        params.require(:return_authorization).permit(:order_id, :return_quantity, :reason, :reason_other)
      end
  end
end
