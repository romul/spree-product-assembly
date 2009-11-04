require 'test/test_helper'

class InventoryUnitTest < ActiveSupport::TestCase
  context InventoryUnit do
    setup do
      @product = Factory(:product)
      
      @part_product_1 = Factory(:product, :can_be_part => true)
      @part1 = @part_product_1.master
      @part1.on_hand = 5
      
      @part_product_2 = Factory(:product, :can_be_part => true)
      @part2 = @part_product_2.master
      @part2.on_hand = 16
            
      @product.add_part @part1, 1
      @product.add_part @part2, 4
      
      line_item = Factory(:line_item, :variant => @product.master)
      
      @order = line_item.order.reload
    end
    context "when sold" do
      setup do
        InventoryUnit.sell_units(@order)
      end
      should "selling parts" do
        assert_equal  4, @part1.on_hand
        assert_equal 12, @part2.on_hand
      end      
      should "associate the inventory units with the order" do
        @part1.inventory_units.select{|iu| iu.state == 'sold'}.each do |inv_unit|
          assert_equal @order, inv_unit.order
        end
        @part2.inventory_units.select{|iu| iu.state == 'sold'}.each do |inv_unit|
          assert_equal @order, inv_unit.order
        end        
      end
    end
  end   
end
