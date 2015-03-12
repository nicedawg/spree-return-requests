module Spree
  class ReturnAuthorizationsController < Spree::StoreController

    before_filter :check_authorization
    before_filter :ensure_order_has_shipped_units
    before_filter :ensure_order_is_within_return_window

    def new
      @return_authorization = Spree::ReturnAuthorization.new(order: @order)
    end

    def create
      @return_authorization = Spree::ReturnAuthorization.new(permitted_params)
      @return_authorization.order = @order

      if @return_authorization.save!
        (params[:return_quantity] || []).each { |variant_id, qty| @return_authorization.add_variant(variant_id.to_i, qty.to_i) }

        redirect_to spree.new_return_request_path, flash: { success: Spree.t(:return_requests_return_authorization_succesfully_created) }
        return
      else
        render :new
      end
    end

    private

      def check_authorization
        session[:access_token] = params[:token] if params[:token]
        @order = Spree::Order.find_by_number(params[:order_id])
        authorize! :read, @order, session[:access_token]
      end

      def ensure_order_has_shipped_units
        unless @order.shipped?
          destination = request.env['HTTP_REFERER'] || root_url
          redirect_to destination, flash: { error: Spree.t(:return_requests_order_must_be_shipped) }
          return
        end
      end

      def ensure_order_is_within_return_window
        if @order.completed_at < SpreeReturnRequests::Config[:return_request_max_order_age_in_days].days.ago
          destination = request.env['HTTP_REFERER'] || root_url
          redirect_to destination, flash: { error: Spree.t(:return_requests_order_not_within_return_window) }
          return
        end
      end

      def permitted_params
        params.require(:return_authorization).permit(:order_id, :return_quantity, :reason)
      end
  end
end
