module Spree
  InventoryUnit.class_eval do
    belongs_to :line_item, class_name: "Spree::LineItem"
  end
end
