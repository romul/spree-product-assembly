require 'spec_helper'

module Spree
  module Stock
    describe Coordinator do
      include_context "product is ordered as individual and within a bundle"

      subject { Coordinator.new(order) }

      before { StockItem.update_all 'count_on_hand = 10' }

      context "bundle part requires more units than individual product" do
        before { order.contents.add(bundle_variant, 5) }

        let(:bundle_item_quantity) { order.find_line_item_by_variant(bundle_variant).quantity }

        it "calculates items quantity properly" do
          expected_units_on_package = order.line_items.sum(&:quantity) - bundle_item_quantity + (bundle.parts.count * bundle_item_quantity)

          expect(subject.packages.sum(&:quantity)).to eql expected_units_on_package
        end
      end
    end
  end
end
