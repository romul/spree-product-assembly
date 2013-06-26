require 'spec_helper'

module Spree
  describe LineItem do
    let!(:order) { create(:order_with_line_items) }
    let(:line_item) { order.line_items.first }
    let(:product) { line_item.product }
    let(:inventory) { double('inventory') }

    context "updates bundle product line item" do
      let(:parts) { (1..2).map { create(:variant) } }

      before do
        product.parts << parts
        order.create_proposed_shipments
        order.finalize!
      end

      it "verifies inventory units via OrderIventoryAssembly" do
        OrderInventoryAssembly.should_receive(:new).with(line_item).and_return(inventory)
        inventory.should_receive(:verify).with(line_item.target_shipment)
        line_item.save
      end

      it "destroys units along with line item" do
        expect(OrderInventoryAssembly.new(line_item).inventory_units).not_to be_empty
        line_item.destroy_along_with_units
        expect(InventoryUnit.where(line_item_id: line_item.id).to_a).to be_empty
      end
    end

    context "updates regular line item" do
      it "verifies inventory units via OrderInventory" do
        OrderInventory.should_receive(:new).with(line_item.order).and_return(inventory)
        inventory.should_receive(:verify).with(line_item, line_item.target_shipment)
        line_item.save
      end
    end
  end
end
