class CreateSpreeReturnRequests < ActiveRecord::Migration
  def change
    create_table :spree_return_requests do |t|
      t.references :order, index: true
      t.string :email_address
      t.timestamp :submitted_at
      t.string :status

      t.timestamps
    end
  end
end
