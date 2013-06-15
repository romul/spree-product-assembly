module Spree
  module Stock
    Package.class_eval do
      AssemblyContentItem = Struct.new(:variant, :quantity, :state, :line_item)

      # TODO Maybe we don't need to override this method
      #
      # Instead we could add a `package.add_bundle_part` or something like
      # that so that we could use this while adding parts of a bundle 
      # and the spree core `package.add` to add invidual (regular) products.
      # This will make the extension play way more well with Spree coder
      # default internals. Just need to keep in mind that to do that we need
      # make the ContentItem respond to `line_item`
      def add(variant, quantity, state=:on_hand, line_item = nil)
        contents << AssemblyContentItem.new(variant, quantity, state, line_item)
      end

      # When searching for an item it needs to check also if line item matches
      # otherwise the first item found may not be exactly the one you'd expect
      #
      # e.g.
      # Customer ordered three bundles and one individual regular product
      # The bundle includes the product ordered individually as a part
      #
      # When searching for the item it may will not distinguish the product
      # from the part, as they really the same variant. The side effect is
      # that the Priotirizer or the Adjuster may increase / decrease the
      # quantity of the item as it will believe that the package has more
      # than the variant on the order actually needs.
      #
      # Following the example above the prioritizer may remove two of the
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
