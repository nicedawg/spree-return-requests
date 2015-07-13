module Spree
  class ReturnAuthorizationsController < Spree::StoreController

    before_filter :load_return_authorization, only: [:labels]
    before_filter :load_order, only: [:labels]
    before_filter :check_authorization, only: [:new, :create, :labels]
    before_filter :ensure_order_has_shipped_units, only: [:new, :create]
    before_filter :ensure_order_is_within_return_window, only: [:new, :create]

    def new
      @return_authorization = Spree::ReturnAuthorization.new(order: @order)
      @return_authorization.being_submitted_by_client = true
    end

    def create
      @return_authorization = Spree::ReturnAuthorization.new(permitted_params)
      @return_authorization.being_submitted_by_client = true
      @return_authorization.order = @order
      @return_authorization.return_quantity = params[:return_quantity]
      @return_authorization.return_reason = params[:return_reason]
      @return_authorization.return_comments = params[:return_comments]
      @return_authorization.total_returned_qty = total_returned_qty

      if @return_authorization.save
        (params[:return_quantity] || []).each { |variant_id, qty| @return_authorization.add_variant(variant_id.to_i, qty.to_i) }
        @return_authorization.amount = @return_authorization.compute_returned_amount

        # add reasons and comments for each "line item"
        (params[:return_reason] || []).each do |variant_id, reason|
          comments = params[:return_comments] ? params[:return_comments][variant_id] : nil
          next unless comments.present? || reason.present?
          variant = Spree::Variant.find variant_id
          return_info = @return_authorization.get_return_info_for_variant(variant)
          return_info.reason = reason
          return_info.comments = comments
          return_info.save!
        end

        if @return_authorization.save
          @message = SpreeReturnRequests::Config[:return_request_success_text]
          render :success
          return
        end
      end

      render :new
    end

    def labels
    end

    def search
      @errors = []

      if params.include?(:order)
        @errors << "Order Number is required." unless params[:order][:order_number].present?
        @errors << "Email Address is required." unless params[:order][:email_address].present?

        if params[:order][:order_number].present? && params[:order][:email_address].present?
          order = Spree::Order.where(number: params[:order][:order_number].strip, email: params[:order][:email_address].strip).first

          if order
            redirect_to(new_order_return_authorization_path(order, params: { token: order.token })) && return
          else
            @errors << "Order not found."
          end
        end
      end
    end

    private

      def load_return_authorization
        @return_authorization = Spree::ReturnAuthorization.find_by_number params[:id]
        if @return_authorization.nil?
          flash[:error] = "You do not have access to this return."
          redirect_to(orders_return_authorizations_search_path) && return
        end
      end

      def load_order
        params[:order_id] = @return_authorization.order.number
      end

      def check_authorization
        session[:access_token] = params[:token] if params[:token]
        begin
          @order = Spree::Order.find_by_number(params[:order_id])
          authorize! :read, @order, session[:access_token]
        rescue
          flash[:error] = "You do not have access to this order."
          redirect_to(orders_return_authorizations_search_path) && return
        end
      end

      def total_returned_qty
        total_qty = 0
        params[:return_quantity].each { |variant_id, qty| total_qty += qty.to_i }
        total_qty
      end

      def ensure_order_has_shipped_units
        unless @order.shipped?
          @error = Spree.t(:return_requests_order_must_be_shipped)
          render :error
          return
        end
      end

      def ensure_order_is_within_return_window
        if @order.completed_at < SpreeReturnRequests::Config[:return_request_max_order_age_in_days].days.ago
          @error = SpreeReturnRequests::Config[:return_request_past_return_window_text]
          render :error
          return
        end
      end

      def permitted_params
        params.permit(:return_authorization, :order_id, :reason, :reason_other)
      end
  end
end
