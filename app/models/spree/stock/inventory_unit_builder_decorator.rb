module Spree
  module Stock
    InventoryUnitBuilder.class_eval do
      def units
        nested_units = @order.line_items.flat_map do |line_item|
          line_item.quantity.times.map do |i|
            product = line_item.product
            if product.assembly?
              line_item.parts.map { |part| build_inventory_unit(part, line_item) }
            else
              build_inventory_unit(line_item.variant, line_item)
            end
          end
        end
        nested_units.flatten
      end

      def build_inventory_unit(variant, line_item)
        @order.inventory_units.includes(
          variant: {
            product: {
              shipping_category: {
                shipping_methods: [:calculator, { zones: :zone_members }]
              }
            }
          }
        ).build(
          pending: true,
          variant: variant,
          line_item: line_item,
          order: @order
        )
      end
    end
  end
end
