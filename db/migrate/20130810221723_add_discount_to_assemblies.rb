class AddDiscountToAssemblies < ActiveRecord::Migration
  def up
    change_table(:spree_products) do |t|
      t.column :discount, :decimal, :precision => 4, :scale => 2
    end 
  end
  
  def down
    change_table(:spree_products) do |t|
      t.remove :discount
    end 
  end
end
