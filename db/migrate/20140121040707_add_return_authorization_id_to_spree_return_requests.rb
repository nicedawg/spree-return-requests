class AddReturnAuthorizationIdToSpreeReturnRequests < ActiveRecord::Migration
  def change
    add_column :spree_return_requests, :return_authorization_id, :integer
    add_index :spree_return_requests, :return_authorization_id
  end
end
