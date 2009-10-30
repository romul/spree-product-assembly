require File.dirname(__FILE__) + '/../test_helper'

class ProductAssemblyExtensionTest < Test::Unit::TestCase
  
  # Replace this with your real tests.
  def test_this_extension
    flunk
  end
  
  def test_initialization
    assert_equal File.join(File.expand_path(RAILS_ROOT), 'vendor', 'extensions', 'product_assembly'), ProductAssemblyExtension.root
    assert_equal 'Product Assembly', ProductAssemblyExtension.extension_name
  end
  
end
