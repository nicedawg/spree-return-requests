class CreateSpreeLineItemReturnInfo < ActiveRecord::Migration
  def change
    create_table :spree_line_item_return_infos do |t|
      t.references :return_authorization, index: true
      t.references :line_item, index: true
      t.string :reason
      t.text :comments
    end
  end
end
