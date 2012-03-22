Deface::Override.new(:virtual_path => "spree/admin/shared/_product_tabs",
                     :name => "product_assembly_admin_product_tabs",
                     :insert_bottom => "[data-hook='admin_product_tabs']",
                     :partial => "spree/admin/shared/product_assembly_product_tabs",
                     :disabled => false)
