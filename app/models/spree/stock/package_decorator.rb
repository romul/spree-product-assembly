module Spree
  module Stock
    Package.class_eval do
      # Overriden from Spree core
      #
      # Package contents need to have a line item as well so we can tell
      # whether the item comes a product assembly or from a regular product
      #
      # Returns the updated contents array
      def add(variant, quantity, state=:on_hand, line_item = nil)
        contents << OpenStruct.new(variant: variant, quantity: quantity, state: state, line_item: line_item)
      end

      # Overriden from Spree core
      #
      # When searching for an item it needs to check also if line item matches
      # otherwise the first item found may not be exactly the one you'd expect
      #
      # e.g.
      # Customer ordered 3 bundles and 1 individual regular product
      # The bundle includes the product ordered individually as a part
      #
      # When searching for the item it may not distinguish the product
      # from the part, as they really the same variant. The side effect is
      # that the Priotirizer or the Adjuster may increase / decrease the
      # quantity of the item as it will believe that the package has more,
      # or less, than the variant on the order actually needs.
      #
      # Following the example above the prioritizer may remove 2 of the
      # bundle parts because it would think that the order actually only
      # needs one (the quantity customer ordered for the individual product),
      # the Coordinator spec has a use case for that
      def find_item(variant, state = :on_hand, line_item = nil)
        contents.select do |item|
          item.variant == variant &&
          item.state == state &&
          item.line_item == line_item
        end.first
      end

      # Overriden to link an inventory unit to a line item
      def to_shipment
        shipment = Spree::Shipment.new
        shipment.order = order
        shipment.stock_location = stock_location
        shipment.shipping_rates = shipping_rates

        contents.each do |item|
          item.quantity.times do |n|
            unit = shipment.inventory_units.build
            unit.pending = true
            unit.order = order
            unit.variant = item.variant
            unit.line_item = item.line_item
            unit.state = item.state.to_s
          end
        end

        shipment
      end
    end
  end
end
