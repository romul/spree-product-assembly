require 'spec_helper'

module Spree
  describe OrderInventory do
    let(:order) { Order.create }

    subject { OrderInventory.new(order) }

    context "regular orders, not mixing parts and regular products" do
      let(:variant) { create(:variant) }
      let(:shipment) { create(:shipment) }
      let(:stock_location) { shipment.stock_location }
      let(:stock_item) { stock_location.stock_item_or_create(variant) }

      before do
        stock_item.adjust_count_on_hand(5)
        order.contents.add(variant, 10)
      end

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

    context "same variant within bundle and as regular product" do
      let(:contents) { OrderContents.new(order) }
      let(:guitar) { create(:variant) }
      let(:bass) { create(:variant) }

      let(:bundle) { create(:product) }

      before { bundle.parts.push [guitar, bass] }

      let!(:bundle_item) { contents.add(bundle.master, 5) }
      let!(:guitar_item) { contents.add(guitar, 3) }

      let!(:shipment) { order.create_proposed_shipments.first }

      context "completed order" do
        before { order.touch :completed_at }

        it "removes only units associated with provided line item" do
          expect {
            subject.send(:remove_from_shipment, shipment, guitar_item, 5)
          }.not_to change { bundle_item.inventory_units.count }
        end
      end
    end
  end
end
