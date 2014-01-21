class Spree::Admin::ReturnRequestsController < Spree::Admin::ResourceController

  before_filter :find_return_request, only: [:show, :approve, :deny]

  def index
    @types = %w[pending approved denied]
    params[:type] ||= "pending"
    @requests = Spree::ReturnRequest.submitted.by_status(params[:type])
  end

  def show
  end

  def approve
    @return_request.status = "approved"
    if @return_request.save
      redirect_to admin_return_requests_url, flash: { success: "Return Request approved." }
    else
      flash.now[:error] = "Failed to approve return request."
      render :show
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
