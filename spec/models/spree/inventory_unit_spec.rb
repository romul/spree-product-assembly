require 'spec_helper'

module Spree
  describe InventoryUnit do
    let!(:order) { create(:order_with_line_items) }
    let(:line_item) { order.line_items.first }
    let(:product) { line_item.product }

    subject { InventoryUnit.create(line_item: line_item, variant: line_item.variant, order: order) }

    context 'if the unit is not part of an assembly' do      
      it 'it will return the percentage of a line item' do
        expect(subject.percentage_of_line_item).to eql(BigDecimal.new(1))
      end
    end

    context 'if part of an assembly' do
      let(:parts) { (1..2).map { create(:variant) } }

      before do
        product.parts << parts
        order.create_proposed_shipments
        order.finalize!
      end

      it 'it will return the percentage of a line item' do
        subject.line_item = line_item
      	expect(subject.percentage_of_line_item).to eql(BigDecimal.new(0.5, 2))
      end
    end
  end
end
