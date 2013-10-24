require 'spec_helper'

module Spree
  describe OrderContents do
    let(:order) { Order.create }

    let(:guitar) { create(:variant) }
    let(:bass) { create(:variant) }

    let(:bundle) { create(:product) }

    subject { OrderContents.new(order) }

    before { bundle.parts.push [guitar, bass] }

    context "same variant within bundle and as regular product" do
      let!(:guitar_item) { subject.add(guitar, 3) }
      let!(:bundle_item) { subject.add(bundle.master, 5) }

      it "destroys the variant as regular product only" do
        subject.remove(guitar, 3)
        expect(order.reload.line_items.to_a).to eq [bundle_item]
      end

      context "completed order" do
        before do
          order.create_proposed_shipments
          order.touch :completed_at
        end

        it "destroys accurate number of inventory units" do
          expect {
            subject.remove(guitar, 3)
          }.to change { InventoryUnit.count }.by(-3)
        end
      end
    end
  end
end
