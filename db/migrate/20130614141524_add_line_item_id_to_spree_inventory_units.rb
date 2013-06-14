class AddLineItemIdToSpreeInventoryUnits < ActiveRecord::Migration
  def change
    add_column :spree_inventory_units, :line_item_id, :integer
    add_index :spree_inventory_units, :line_item_id
  end
end
