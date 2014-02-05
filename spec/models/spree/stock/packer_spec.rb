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

        it 'adds all bundle parts to the shipment' do
          package = subject.product_assembly_package
          package.contents.size.should eq 4 + parts.count
        end

        context "order has backordered and on hand items" do
          before do
            stock_item = stock_location.stock_item(parts.first)
            stock_item.adjust_count_on_hand(10)
          end

          it "splits package in two as expected (backordered, on_hand)" do
            expect(subject.packages.count).to eql 2
          end
        end

        context "store doesn't track inventory" do
          before { Spree::Config.track_inventory_levels = false }
          
          it 'adds items as on-hand, not backordered' do
            stock_item = stock_location.stock_item(order.line_items.first)
            
            package = subject.product_assembly_package
            package.contents.size.should eq 4 + parts.count
            package.contents.each {|ci| ci.state.should eq :on_hand}
          end
        end
      
        context "are tracking inventory" do
          before do
            Spree::Config.track_inventory_levels = true
            # by default, variant factory sets track_inventory to true
          end
          
          it 'adds items as backordered' do
            package = subject.product_assembly_package
            package.contents.size.should eq 4 + parts.count
            package.contents.each {|ci| ci.state.should eq :backordered}
          end
        end
      
        context 'variants and parts do not track inventory' do
          before(:each) do
            Spree::Config.track_inventory_levels = true
            order.line_items.each do |li| 
              li.variant.track_inventory = false
              li.save!
              if li.product.assembly?
                li.product.parts.each do |part|
                  part.track_inventory = false
                  part.save!
                end
              end
            end
          end
          
          it 'adds items as on-hand, not backordered' do
            package = subject.product_assembly_package
            package.contents.size.should eq 4 + parts.count
            package.contents.each {|ci| ci.state.should eq :on_hand}
          end
        end
      end
    end
  end
end
