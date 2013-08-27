require 'spec_helper'

module Spree
  describe Shipment do
    context "order has one product assembly" do
      let(:order) { Order.create }
      let(:bundle) { create(:variant) }
      let!(:parts) { (1..2).map { create(:variant) } }
      let!(:bundle_parts) { bundle.product.parts << parts }

      let!(:line_item) { order.contents.add(bundle, 1) }
      let!(:shipment) { order.create_proposed_shipments.first }

      before { order.update_column :state, 'complete' }

      it "shipment item cost equals line item amount" do
        expect(shipment.item_cost).to eq line_item.amount
      end
    end

    context "manifests" do
      include_context "product is ordered as individual and within a bundle"

      let(:shipments) { order.create_proposed_shipments }

      context "default" do
        let(:expected_variants) { order.variants - [bundle_variant] + bundle.parts }

        it "separates variant purchased individually from the bundle one" do
          expect(shipments.count).to eql 1
          shipments.first.manifest.map(&:variant).sort.should == expected_variants.sort
        end
      end

      context "line items manifest" do
        let(:expected_variants) { order.variants }

        it "groups units by line_item only" do
          expect(shipments.count).to eql 1
          shipments.first.line_item_manifest.map(&:variant).sort.should == expected_variants.sort
        end
      end

      context "units are not associated with a line item" do
        let(:order) { create(:shipped_order) }
        let(:shipment) { order.shipments.first }

        it "searches for line item if inventory unit doesn't have one" do
          shipment.manifest.last.line_item.should_not be_blank
        end
      end
    end
  end
end
