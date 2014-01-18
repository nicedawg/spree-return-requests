class Spree::ReturnRequestsController < ApplicationController
  def index
    redirect_to spree.new_return_request_path
  end

  def new
  end

  def create
    @return_request = Spree::ReturnRequest.new(params[:return_request])

    if @return_request.save
      redirect_to spree.edit_return_request_path(@return_request)
    else
      flash.now[:error] = @return_request.errors.full_messages.to_sentence
      render :new and return
    end
  end

  def edit
    @return_request = Spree::ReturnRequest.find(params[:id])
    @order = @return_request.order

    # TODO: build out stub records for items ordered

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
      redirect_to spree.edit_return_request_url(@return_request), flash: { success: "Return request updated." } and return
    else
      flash.now[:error] = @return_request.errors.full_messages.to_sentence
      render :edit and return
    end
  end
end
