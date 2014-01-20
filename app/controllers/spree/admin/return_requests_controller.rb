class Spree::Admin::ReturnRequestsController < Spree::Admin::ResourceController

  def index
    @types = %w[pending approved denied]
    params[:type] ||= "pending"
    @requests = Spree::ReturnRequest.submitted.by_status(params[:type])
  end

  def show
    @request = Spree::ReturnRequest.find(params[:id])
  end
end
