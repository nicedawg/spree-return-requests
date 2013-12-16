class CreateSpreeReturnRequestLineItems < ActiveRecord::Migration
  def change
    create_table :spree_return_request_line_items do |t|
      t.references :spree_return_request, index: true
      t.references :line_item, index: true
      t.integer :qty

      t.timestamps
    end
  end
end
