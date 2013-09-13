module Spree
  OrderInventory.class_eval do
    # Overriden from Spree core only to pass a line_item to `add_to_shipment`
    #
    # TODO this might not be necessary if we change the OrderInventory API
    # to receive a line item on initialization rather than an order object
    def verify(line_item, shipment = nil)
      if order.completed? || shipment.present?

        variant_units = inventory_units_for(line_item.variant)

        if variant_units.size < line_item.quantity
          quantity = line_item.quantity - variant_units.size

          shipment = determine_target_shipment(line_item.variant) unless shipment
          add_to_shipment(shipment, line_item.variant, quantity, line_item)
        elsif variant_units.size > line_item.quantity
          remove(line_item, variant_units, shipment)
        end
      else
        true
      end
    end

    private
      # Overriden from Spree core to associate a line item with a inventory unit
      #
      # Even though the variant here will always be the same of line_item.variant
      # this helps on the visual result when grouping inventory units on a
      # shipment manifest which might also contain a bundle part
      #
      # TODO too much override for a very small change. need to find a better way
      # to override only what matters. e.g. changing the internals of OrderInventory
      # and/or InventoryUnit on spree core
      def add_to_shipment(shipment, variant, quantity, line_item)
        on_hand, back_order = shipment.stock_location.fill_status(variant, quantity)

        on_hand.times { shipment.set_up_inventory('on_hand', variant, order, line_item) }
        back_order.times { shipment.set_up_inventory('backordered', variant, order, line_item) }

        if order.completed?
          shipment.stock_location.unstock variant, quantity, shipment
        end

        quantity
      end
  end
end
