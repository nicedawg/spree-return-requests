class Spree::ReturnRequestsController < ApplicationController
  def index
    redirect_to spree.new_return_request_path
  end

  def new
  end

  def create
    begin
      order_number = params[:return_request].delete("order_number")
      order = Spree::Order.where(number: order_number).first
      params[:return_request][:order] = order
      return_request = Spree::ReturnRequest.create!(params[:return_request])
    rescue Exception => e
      flash[:error] = e.to_s
      render :new and return
    end
    redirect_to spree.edit_return_request_path(return_request)
  end

  def edit
    @return_request = Spree::ReturnRequest.find(params[:id])
    @order = @return_request.order

    if @return_request.submitted_at
      redirect_to spree.return_requests_url, flash: { error: "You can't edit submitted return requests." } and return
    end
  end

  def update
    @return_request = Spree::ReturnRequest.find(params[:id])

    if @return_request.submitted_at
      redirect_to spree.return_requests_url, flash: { error: "You can't update submitted return requests." } and return
    end

    if @return_request.update_attributes(params[:return_request])
      @return_request.submitted_at = DateTime.now
      @return_request.status = "pending"
      @return_request.save!
      redirect_to spree.edit_return_request_url(@return_request), flash: { error: "Return request updated." } and return
    else
      render :edit, flash: { error: "Something bad happened" } and return
    end
  end
end
