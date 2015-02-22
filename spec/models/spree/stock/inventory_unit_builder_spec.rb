require 'spec_helper'

module Spree
  module Stock
    describe InventoryUnitBuilder, :type => :model do
      subject { InventoryUnitBuilder.new(order) }
      
      context "order shares variant as individual and within bundle" do
        include_context "product is ordered as individual and within a bundle" do
          let(:bundle_item_quantity) { order.find_line_item_by_variant(bundle_variant).quantity }

          describe "#units" do
            it "returns an inventory unit for each part of each quantity for the order's line items" do
              units = subject.units
              expect(units.count).to eq 4
              expect(units[0].line_item.quantity).to eq order.line_items.first.quantity
              expect(units[0].line_item.quantity).to eq bundle_item_quantity

              line_item = order.line_items.first

              expect(units.map(&:variant)).to match_array line_item.parts
            end

            it "builds the inventory units as pending" do
              expect(subject.units.map(&:pending).uniq).to eq [true]
            end

            it "associates the inventory units to the order" do
              expect(subject.units.map(&:order).uniq).to eq [order]
            end
          end
        end
      end
    end
  end
end
