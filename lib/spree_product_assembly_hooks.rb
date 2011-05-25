Deface::Override.new(:virtual_path => "admin/shared/_product_tabs",
                     :name => "product_assembly_admin_product_tabs",
                     :insert_bottom => "[data-hook='admin_product_tabs']",
                     :partial => "admin/shared/product_assembly_product_tabs",
                     :disabled => false)

Deface::Override.new(:virtual_path => "orders/_line_item",
                     :name => "product_assembly_cart_item_description",
                     :insert_bottom => "[data-hook='cart_item_description']",
                     :partial => "orders/cart_description",
                     :disabled => false)

Deface::Override.new(:virtual_path => "admin/products/_form",
                     :name => "product_assembly_admin_product_form_right",
                     :insert_after => "[data-hook='admin_product_form_right'], #admin_product_form_right[data-hook]",
                     :partial => "admin/products/product_assembly_fields",
                     :disabled => false)
                     
