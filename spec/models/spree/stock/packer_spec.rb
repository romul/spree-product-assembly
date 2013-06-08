require 'spec_helper'

module Spree
  module Stock
    describe Packer do
      let!(:order) { create(:order_with_line_items, line_items_count: 5) }
      let!(:stock_location) { create(:stock_location) }

      subject { Packer.new(stock_location, order) }

      context 'packages' do
        it 'builds an array of packages' do
          packages = subject.packages
          packages.size.should eq 1
          packages.first.contents.size.should eq 5
        end
      end

      context 'product assembly package' do
        let(:part) { create(:variant) }

        before do
          Product.last.parts << part
        end

        it 'contains all the items + part quantity included' do
          package = subject.product_assembly_package
          package.contents.size.should eq 6
        end

        context "location doesn't have order items in stock" do
          let(:stock_location) { create(:stock_location, propagate_all_variants: false) }
          let(:packer) { Packer.new(stock_location, order) }

          it "builds an empty package" do
            packer.product_assembly_package.contents.should be_empty
          end
        end
      end
    end
  end
end
