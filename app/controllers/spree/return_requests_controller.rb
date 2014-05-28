class Spree::ReturnRequestsController < Spree::StoreController

  before_filter :find_return_request, :prevent_updating_submitted_requests, only: [:edit, :update]
  before_filter :build_line_items, only: [:edit]

  def index
    redirect_to spree.new_return_request_path
  end

  def new
  end

  def create
    @return_request = Spree::ReturnRequest.new(permitted_params)

    if @return_request.save
      redirect_to spree.edit_return_request_path(@return_request)
    else
      flash.now[:error] = @return_request.errors.full_messages.to_sentence
      render :new and return
    end
  end

  def edit
  end

  def update
    if @return_request.update_attributes(permitted_params)
      if @return_request.reload.submitted_at
        Spree::ReturnRequestsMailer.submitted(@return_request).deliver
        Spree::ReturnRequestsMailer.submitted_admin(@return_request).deliver
        render :thank_you
        return
      end
      redirect_to spree.edit_return_request_url(@return_request), flash: { success: "Return request updated." } and return
    else
      flash.now[:error] = @return_request.errors.full_messages.to_sentence
      render :edit and return
    end
  end

  private

    def permitted_params
      params.require(:return_request).permit(:order, :order_id, :order_number, :email_address, :ready_to_submit, :reason, :return_request_line_items_attributes => [:line_item, :line_item_id, :qty])
    end

    def find_return_request
      @return_request = Spree::ReturnRequest.find(params[:id])
    end

    def build_line_items
      unless @return_request.line_items.any?
        @return_request.order.line_items.each do |li|
          @return_request.line_items.build(line_item: li, qty: 0)
        end
      end
    end

    def prevent_updating_submitted_requests
      redirect_to spree.new_return_request_url, flash: { error: "You can't edit submitted return requests." } and return if @return_request.submitted_at
    end
end
