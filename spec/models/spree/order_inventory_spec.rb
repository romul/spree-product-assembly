require 'spec_helper'

module Spree
  describe OrderInventory do
    let(:order) { Order.create }
    let(:variant) { create(:variant) }
    let(:shipment) { create(:shipment) }
    let(:stock_location) { shipment.stock_location }

    before do
      stock_location.stock_item_or_create(variant).adjust_count_on_hand(5)
      order.contents.add(variant, 10)
    end

    subject { OrderInventory.new(order) }

    it "properly creates inventory units" do
      subject.verify(order.line_items.first, shipment)
      expect(InventoryUnit.count).to eq 10
    end
  end
end
