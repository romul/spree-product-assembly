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

      context 'package bundle product parts' do
        let(:variant) { create(:variant) }
        let(:parts) { [variant, variant, variant] }

        before do
          Product.last.parts << parts
        end

        it 'adds all bundle parts to the shipent' do
          package = subject.product_assembly_package
          package.contents.size.should eq 4 + parts.count
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
