require 'spec_helper'

module Spree
  describe LineItem do
    let!(:order) { create(:order_ready_to_ship) }
    let(:line_item) { order.line_items.first }
    let(:product) { line_item.product }
    let(:inventory) { double('inventory') }

    context "updates bundle product line item" do
      let(:parts) { (1..2).map { create(:variant) } }

      before { product.parts << parts }

      it "verifies inventory units via OrderIventoryAssembly" do
        OrderInventoryAssembly.should_receive(:new).with(line_item).and_return(inventory)
        inventory.should_receive(:verify).with(line_item.target_shipment)
        line_item.save
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
