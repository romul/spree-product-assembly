require 'spec_helper'

describe Spree::InventoryUnit do
  before(:each) do
    @product = Factory(:product)
    
    @part_product_1 = Factory(:product, :can_be_part => true)
    @part1 = @part_product_1.master
    @part1.on_hand = 5
    @part1.save
    
    @part_product_2 = Factory(:product, :can_be_part => true)
    @part2 = @part_product_2.master
    @part2.on_hand = 16
    @part2.save
    
    @product.add_part @part1, 1
    @product.add_part @part2, 4
    
    line_item = Factory(:line_item, :variant => @product.master, :quantity => 2)
    
    @order = line_item.order.reload
    # completed? relies on completed_at timestamp
    @order.update_attribute(:completed_at, Time.now)
  end
  
  describe "when an order is finalized " do
    before(:each) do
      Spree::InventoryUnit.assign_opening_inventory @order
    end
    
    it "assigns to the parts' variants on #assign_opening_inventory" do
      @part1.reload.on_hand.should == 3
      @part2.reload.on_hand.should == 8
    end
    
    it "associates the inventory units with the order" do
      @part1.inventory_units.select{|iu| iu.state == 'sold'}.each do |inv_unit|
        inv_unit.order.should == @order
      end
      
      @part2.inventory_units.select{|iu| iu.state == 'sold'}.each do |inv_unit|
        inv_unit.order.should == @order
      end
    end
  end
end
