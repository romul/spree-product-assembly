class AddPartsFieldsToProducts < ActiveRecord::Migration
  def self.up
    change_table(:products) do |t|
      t.column :can_be_part, :boolean, :default => false, :null => false
      t.column :individual_sale, :boolean, :default => true, :null => false
    end  
  end

  def self.down
    change_table(:products) do |t|
      t.remove :can_be_part
      t.remove :individual_sale
    end
  end
end
