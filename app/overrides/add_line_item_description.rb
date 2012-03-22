Deface::Override.new(:virtual_path => "spree/orders/_line_item",
                     :name => "product_assembly_cart_item_description",
                     :insert_bottom => "[data-hook='cart_item_description']",
                     :partial => "spree/orders/cart_description",
                     :disabled => false)
