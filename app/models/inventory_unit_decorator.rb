InventoryUnit.class_eval do
  def self.sell_units(order)
    # we should not already have inventory associated with the order at this point but we should clear to be safe (#1394)
    order.inventory_units.destroy_all

    out_of_stock_items = []
    order.line_items.each do |line_item|
      variant = line_item.variant
      quantity = line_item.quantity
      product = variant.product

      if product.assembly?
        product.parts.each do |v|
          out_of_stock_items += create_units(order, v, quantity * product.count_of(v))
        end
      else
        out_of_stock_items += create_units(order, variant, quantity)
      end
    end
    out_of_stock_items.flatten
  end

  def self.adjust_units(order)
    units_by_variant = order.inventory_units.group_by(&:variant_id)
    out_of_stock_items = []

    #check line items quantities match
    order.line_items.each do |line_item|
      if line_item.variant.product.assembly?

        line_item.variant.product.parts.each do |variant|
          quantity = line_item.quantity
          unit_count = units_by_variant.key?(variant.id) ? units_by_variant[variant.id].size : 0

          adjust_line(variant, quantity, unit_count, order, out_of_stock_items, units_by_variant)

          #remove it from hash as it's up-to-date
          units_by_variant.delete(variant.id)
        end

      else
        variant = line_item.variant
        quantity = line_item.quantity
        unit_count = units_by_variant.key?(variant.id) ? units_by_variant[variant.id].size : 0

        adjust_line(variant, quantity, unit_count, order, out_of_stock_items, units_by_variant)

        #remove it from hash as it's up-to-date
        units_by_variant.delete(variant.id)
      end

    end

    #check for deleted line items (if theres anything left in units_by_variant its' extra)
    units_by_variant.each do |variant_id, units|
      units.each {|unit| unit.restock!}
    end

    out_of_stock_items
  end

  private
    def self.adjust_line(variant, quantity, unit_count, order, out_of_stock_items, units_by_variant)
      if unit_count < quantity
        out_of_stock_items.concat create_units(order, variant, (quantity - unit_count))
      elsif  unit_count > quantity
        (unit_count - quantity).times do
          inventory_unit = units_by_variant[variant.id].pop
          inventory_unit.restock!
        end
      end
    end
end
