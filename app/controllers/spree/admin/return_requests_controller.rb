class Spree::Admin::ReturnRequestsController < Spree::Admin::ResourceController

  before_filter :find_return_request, only: [:show, :approve, :deny]

  def index
    @types = %w[pending approved denied]
    params.delete(:type) unless @types.include?(params[:type])
    params[:type] ||= "pending"
    @requests = Spree::ReturnRequest.submitted.by_status(params[:type])
  end

  def show
  end

  def approve
    begin
      @return_request.approve!
      Spree::ReturnRequestsMailer.approved(@return_request).deliver
      redirect_to edit_admin_order_return_authorization_url(@return_request.order.number, @return_request.return_authorization), flash: { success: "Return Request approved." }
    rescue Exception => e
      flash[:error] = "Failed to approve return request: #{e.message}"
      redirect_to admin_return_request_url(@return_request) and return
    end
  end

  def deny
    @return_request.status = "denied"
    if @return_request.save
      redirect_to admin_return_requests_url, flash: { success: "Return Request denied." }
    else
      flash.now[:error] = "Failed to deny return request."
      render :show
    end
  end

  private

    def find_return_request
      @return_request = Spree::ReturnRequest.find(params[:id])
    end
end
