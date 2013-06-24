require 'spec_helper'

module Spree
  describe LineItem do
    let(:line_item) { Factory(:line_item) }
    let(:order) { line_item.order }
    let(:product) { line_item.product }
    let(:parts) { (1..3).map { Factory(:variant) } }

    context "updates item in completed order" do
      
      before do
        order.completed_at = Time.now
        order.save!
      end

      context "item is a regular product" do
        it "creates inventory units for the product" do
          line_item.update_attributes(quantity: line_item.quantity + 1)
          InventoryUnit.last.variant.should == line_item.variant
        end
      end

      context "item is a bundle" do
        before { product.parts << parts }

        it "creates inventory units for bundle parts" do
          line_item.update_attributes(quantity: line_item.quantity + 1)
          InventoryUnit.last(3).map(&:variant).should == parts
        end
      end
    end
  end
end
