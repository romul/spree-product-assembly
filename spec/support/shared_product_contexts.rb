# Basic sanity check
shared_examples "product should pass basic tests" do
  subject { @product }
  
#  should validate_presence_of :name
  
  it "has a product" do
    @product.should be_a(Spree::Product)
  end
  
  it "has 'Foo Bar' as name" do
    @product.name.should == "Foo Bar"
  end
  
  it "has 'foo-bar' as permalink" do
    @product.permalink.should == "foo-bar"
  end
  
  it "doesnt change permalink when name changes" do
    @product.update_attributes :name => 'Foo BaZ'
    @product.name.should == 'Foo BaZ'
    @product.permalink.should == 'foo-bar'
  end
  
  it "doesnt obscure deleted_at" do
    @product.deleted_at.should be_nil
  end
  
  it "has a price" do
    @product.price.should == 19.99
  end
  
  it "has a master price" do
    @product.price.should == @product.master.price
    assert_equal @product.price, @product.master.price
  end
  
  it "changes master price when price changes" do
    @product.update_attributes(:price => 30.0)
    
    @product.price.should == @product.master.price
    @product.price.should == 30.0
  end
  
  it "changes price when master price changes" do
    @product.master.update_attributes(:price => 50.0)
    
    @product.price.should == @product.master.price
    @product.price.should == 50.0
  end
  
  it "persists a master variant record" do
    @master_variant.should == @product.master
  end
  
  it "has an sku" do
    @product.sku.should == 'ABC'
  end
  
  it 'should change SKUs on product and its master' do
    lambda {@product.sku = "NEWSKU"}.should change(@product.master, :sku).from('ABC').to('NEWSKU')
  end
  
end



# Product w/out inventory units
# the default behavior after product has been created
shared_examples "w/out inventory units" do
  it_behaves_like "product should pass basic tests"
  
  it "returns zero on_hand value" do
    @product.on_hand.should == 0
  end
  
  it "returns true for master.has_stock?" do
    @product.master.in_stock?.should == false
  end
  
  it "returns false for has_stock?" do
    @product.should_not have_stock
  end
end


