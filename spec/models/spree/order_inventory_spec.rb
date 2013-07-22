require 'spec_helper'

module Spree
  describe OrderInventory do
    let(:order) { Order.create }
    let(:variant) { create(:variant) }
    let(:shipment) { create(:shipment) }
    let(:stock_location) { shipment.stock_location }
    let(:stock_item) { stock_location.stock_item_or_create(variant) }

    before do
      stock_item.adjust_count_on_hand(5)
      order.contents.add(variant, 10)
    end

    subject { OrderInventory.new(order) }

    context "order is complete" do
      before { order.finalize! }

      it "unstock items" do
        expect {
          subject.verify(order.line_items.first, shipment)
        }.to change { stock_item.reload.count_on_hand }.by(-10)
      end
    end

    it "doesn't unstock items when order is incomplete" do
      expect {
        subject.verify(order.line_items.first, shipment)
      }.not_to change { stock_item.reload.count_on_hand }
    end

    it "properly creates inventory units" do
      subject.verify(order.line_items.first, shipment)
      expect(InventoryUnit.count).to eq 10
    end
  end
end
