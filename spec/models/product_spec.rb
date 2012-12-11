# Some basic tests for Spree::Product.new vs. Spree::Product.create are defined to test
# that Spree::Product creation vs instantiated behave the normal "rails way"
#
require 'spec_helper'

describe Spree::Product do
  
  before(:each) do
    @product = FactoryGirl.create(:product, :name => "Foo Bar")
    @master_variant = Spree::Variant.find_by_product_id(@product.id, :conditions => ["is_master = ?", true])
  end
    
  it_behaves_like "product should pass basic tests"
  
  describe "New Spree::Product instantiated with on_hand" do
    before(:each) do
      @product = Spree::Product.new(:name => "fubaz", :price => "10.0", :on_hand => 5)
    end

    after(:each) do
      @product.destroy
    end
    
    it "shouldnt have a product id" do
      @product.id.should be_nil
    end
    
    it "has a Spree::Product class" do
      assert @product.is_a?(Spree::Product)
    end
    
    it "has a specified on_hand" do
      @product.on_hand.should == 5
    end
  end
  
  describe "w/ variants" do
    before(:each) do
      @product.variants << FactoryGirl.create(:variant)
      # @first_variant = @product.variants.first
    end
    
    it_behaves_like "product should pass basic tests"
    
    it "has variants" do
      @product.variants.first.should be_a(Spree::Variant)
    end
    
    it "returns true for has_variants?" do
      @product.should have_variants
    end
    
    describe "w/out inventory units" do
      before { @product.variants.first.on_hand = 0 }

      it_behaves_like "w/out inventory units"
    end
  end
  
  
  describe "w/out variants" do
    it_behaves_like "product should pass basic tests"
    
    it "returns false for has_variants?" do
      @product.should_not have_variants
    end
    
    describe "w/out inventory" do
      it_behaves_like "w/out inventory units"
    end
  end

  # in general
  describe "Spree::Product.available" do
    before(:each) do
      Spree::Product.delete_all
      5.times { Factory(:product, :available_on => Time.now - 1.day) }
      Factory(:product, :available_on => Time.now - 15.minutes)
      @future_product = Factory.create(:product, :available_on => Time.now + 2.weeks)
    end
    
    after(:each) do
      Spree::Product.available.destroy_all
      @future_product.destroy
    end
    
    it "only includes available products" do
      Spree::Product.available.size.should == 6
      Spree::Product.available.should_not include(@future_product)
    end
  end

  describe "instance" do
    before(:each) { @product = Factory(:product, :price => 19.99) }
    
    describe "with a change in price" do
      before(:each) do
        @product.price = 1.11
        @product.save
      end
      
      it "changes the save the new master price" do
        @product.reload.price.should == BigDecimal.new("1.11")
      end
    end
  end

  describe "Spree::Product Assembly" do
    before(:each) do
      @product = Factory(:product)
      
      @part_product_1 = Factory(:product, :can_be_part => true)
      @part1 = @part_product_1.master
      @part1.on_hand = 5
      
      @part_product_2 = Factory(:product, :can_be_part => true)
      @part2 = @part_product_2.master
      @part2.on_hand = 16
      
      @product.add_part @part1, 1
      @product.add_part @part2, 4
    end
    
    it "is an assembly" do
      @product.should be_assembly
      @product.on_hand.should == 4 # min_of(5/1, 16/4)
    end
    
    describe "setting on_hand" do
      before(:each) { @product.on_hand = 100 }
      
      it 'should not alter on_hand output' do
        lambda{ @product.on_hand = 100 }.should_not change(@product, :on_hand)
      end
    end
    
    it 'changing part qty changes count on_hand' do
      lambda{@product.set_part_count(@part2, 2)}.should change(@product, :on_hand).by(1).from(4).to(5)
      @product.count_of(@part2).should == 2
    end
  end
end
