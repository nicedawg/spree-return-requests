class ChangeSpreeReturnRequestIdToReturnRequestId < ActiveRecord::Migration
  def change
    rename_column :spree_return_request_line_items, :spree_return_request_id, :return_request_id
  end
end
