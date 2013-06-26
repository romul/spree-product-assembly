# Product Assembly

Create a product which is composed of other products.

## Installation

Add the following line to your Gemfile

    gem "spree_product_assembly", :git => "git://github.com/spree/spree-product-assembly.git"

Run bundle install as well as the extension intall command to copy and run migrations and
append spree_product_assembly to your js manifest file

    bundle install
    rails g spree_product_assembly:install

_Use 1-3-stable branch for Spree 1.3.x compatibility_

_In case you're upgrading from 1-3-stable of this extension you might want to run a
rake task which assigns a line item to your previous inventory units from bundle
products. That is so you have a better view on the current backend UI and avoid
exceptions. No need to run this task if you're not upgrading from product assembly
1-3-stable_

    rake spree_product_assembly:upgrade

# Use

This extension adds a `can_be_part` boolean attribute to the spree_products_table.
You'll need to check that flag on the backend product form so that it can be
be found by the parts search form on the bundle product.

Once a product is included as a _part_ of another it will be included on the order
shipment and inventory units for each part will be created accordingly.
