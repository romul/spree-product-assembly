module Spree
  InventoryUnit.class_eval do
    def percentage_of_line_item
      product = line_item.product
      if product.assembly?
        assembly_value = product.parts.inject(0.0) { |total, part| total += product.count_of(part) * part.price }
        total_value = assembly_value * line_item.quantity
        variant.price / total_value
      else
        1 / BigDecimal.new(line_item.quantity)
      end
    end
  end
end
