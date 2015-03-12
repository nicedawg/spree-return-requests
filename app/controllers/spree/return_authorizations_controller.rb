module Spree
  class ReturnAuthorizationsController < Spree::StoreController

    before_filter :check_authorization
    before_filter :ensure_order_has_shipped_units

    def new
      @return_authorization = Spree::ReturnAuthorization.new(order: @order)
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
  end
end
