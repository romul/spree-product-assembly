class ProductAssemblyHooks < Spree::ThemeSupport::HookListener

  insert_after :admin_product_tabs, "admin/shared/product_assembly_product_tabs"

  insert_after :cart_item_description, "orders/cart_description"

  insert_after :admin_product_form_right , "admin/products/product_assembly_fields"

end
