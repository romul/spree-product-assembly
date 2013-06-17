require 'spec_helper'

module Spree
  module Stock
    describe Packer do
      let!(:order) { create(:order_with_line_items, line_items_count: 5) }
      let!(:stock_location) { create(:stock_location) }
      let(:default_splitters) { Rails.application.config.spree.stock_splitters }

      subject { Packer.new(stock_location, order, default_splitters) }

      context 'packages' do
        it 'builds an array of packages' do
          packages = subject.packages
          packages.size.should eq 1
          packages.first.contents.size.should eq 5
        end
      end

      context 'build bundle product package' do
        let(:parts) { (1..3).map { create(:variant) } }

        before do
          order.products.last.parts << parts
        end

        it 'adds all bundle parts to the shipent' do
          package = subject.product_assembly_package
          package.contents.size.should eq 4 + parts.count
        end

        context "order has backorered and on hand items" do
          before do
            stock_item = stock_location.stock_item(parts.first)
            stock_item.adjust_count_on_hand(10)
          end

          it "splits package in two as expected (backordered, on_hand)" do
            expect(subject.packages.count).to eql 2
          end
        end
      end
    end
  end
end
