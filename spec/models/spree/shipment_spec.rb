require 'spec_helper'

module Spree
  describe Shipment do
    include_context "product is ordered as individual and within a bundle"

    let(:inventory_unit) { create(:inventory_unit) }

    context "manifests" do
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
