class AddReasonToSpreeReturnRequests < ActiveRecord::Migration
  def change
    add_column :spree_return_requests, :reason, :text
  end
end
