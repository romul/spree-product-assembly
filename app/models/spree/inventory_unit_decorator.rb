Spree::InventoryUnit.class_eval do
  # UPGRADE_CHECK 
  
  # Assigns inventory to a newly completed order.
  # Should only be called once during the life-cycle of an order, on transition to completed.
  #
  def self.assign_opening_inventory(order)
    return [] unless order.completed?

    #increase inventory to meet initial requirements
    order.line_items.each do |line_item|
      variant = line_item.variant
      quantity = line_item.quantity
      product = variant.product
      
      if product.assembly?
        product.parts.each { |part| increase(order, part, quantity * product.count_of(part)) }
      else
        increase(order, variant, quantity)
      end
    end
  end
end
