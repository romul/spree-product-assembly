require 'spec_helper'

module Spree
  module Stock
    describe Coordinator do
      subject { Coordinator.new(order) }

      context "order shares variant as individual and within bundle" do
        include_context "product is ordered as individual and within a bundle"

        before { StockItem.update_all 'count_on_hand = 10' }

        context "bundle part requires more units than individual product" do
          before { order.contents.add(bundle_variant, 5) }

          let(:bundle_item_quantity) { order.find_line_item_by_variant(bundle_variant).quantity }

          it "calculates items quantity properly" do
            expected_units_on_package = order.line_items.to_a.sum(&:quantity) - bundle_item_quantity + (bundle.parts.count * bundle_item_quantity)

            expect(subject.packages.sum(&:quantity)).to eql expected_units_on_package
          end
        end
      end

      context "multiple stock locations" do
        let!(:stock_locations) { (1..3).map { create(:stock_location) } }

        let(:order) { create(:order_with_line_items) }
        let(:parts) { (1..3).map { create(:variant) } }

        let(:bundle_variant) { order.variants.first }
        let(:bundle) { bundle_variant.product }

        let(:bundle_item_quantity) { order.find_line_item_by_variant(bundle_variant).quantity }

        before { bundle.parts << parts }

        it "haha" do
          expected_units_on_package = order.line_items.to_a.sum(&:quantity) - bundle_item_quantity + (bundle.parts.count * bundle_item_quantity)
          expect(subject.packages.sum(&:quantity)).to eql expected_units_on_package
        end
      end
    end
  end
end
