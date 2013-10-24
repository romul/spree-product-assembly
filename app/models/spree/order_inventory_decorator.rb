module Spree
  OrderInventory.class_eval do
    # Overriden from Spree core only to pass a line_item to `add_to_shipment`
    #
    # Plus the collection of inventory units is fetched through line items rather
    # than variants. Because a variant can be associated with more than one
    # line item in the same shipment. Fetching inventory units through variants
    # then will likely return the wrong number of units.
    def verify(line_item, shipment = nil)
      if order.completed? || shipment.present?

        units = inventory_units_for_item(line_item)

        if units.size < line_item.quantity
          quantity = line_item.quantity - units.size

          shipment = determine_target_shipment(line_item.variant) unless shipment
          add_to_shipment(shipment, line_item.variant, quantity, line_item)
        elsif units.size > line_item.quantity
          remove(line_item, units, shipment)
        end
      else
        true
      end
    end

    def inventory_units_for_item(line_item)
      line_item.inventory_units
    end

    private
      # Overriden from Spree core
      #
      #   def remove(line_item, variant_units, shipment = nil)
      #     quantity = variant_units.size - line_item.quantity

      #     if shipment.present?
      #       remove_from_shipment(shipment, line_item.variant, quantity)
      #     else
      #       order.shipments.each do |shipment|
      #         break if quantity == 0
      #         quantity -= remove_from_shipment(shipment, line_item.variant, quantity)
      #       end
      #     end
      #   end
      #
      # Here we pass a line_item down the stack, `remove_from_shipment`, rather
      # than a variant. That gives accurate results for orders mixing variants
      # as an assembly part and as a regular product
      def remove(line_item, variant_units, shipment = nil)
        quantity = variant_units.size - line_item.quantity

        if shipment.present?
          remove_from_shipment(shipment, line_item, quantity)
        else
          order.shipments.each do |shipment|
            break if quantity == 0
            quantity -= remove_from_shipment(shipment, line_item, quantity)
          end
        end
      end

      # Overriden from Spree core to associate a line item with a inventory unit
      #
      # Even though the variant here will always be the same of line_item.variant
      # this helps on the visual result when grouping inventory units on a
      # shipment manifest which might also contain a bundle part
      def add_to_shipment(shipment, variant, quantity, line_item)
        on_hand, back_order = shipment.stock_location.fill_status(variant, quantity)

        on_hand.times { shipment.set_up_inventory('on_hand', variant, order, line_item) }
        back_order.times { shipment.set_up_inventory('backordered', variant, order, line_item) }

        if order.completed?
          shipment.stock_location.unstock variant, quantity, shipment
        end

        quantity
      end

      # Overriden from Spree core
      #
      #   shipment_units = shipment.inventory_units_for(variant).reject do |variant_unit|
      #     variant_unit.state == 'shipped'
      #   end.sort_by(&:state)
      #
      # When looping through shipment inventory units we pick the ones that
      # match both variant and line_item. Otherwise we might accidentally remove
      # a part which was also purchased as a regular product
      def remove_from_shipment(shipment, line_item, quantity)
        return 0 if quantity == 0 || shipment.shipped?

        variant = line_item.variant

        shipment_units = shipment.inventory_units_for_item(line_item, variant).reject do |unit|
          unit.state == 'shipped'
        end.sort_by(&:state)

        removed_quantity = 0

        shipment_units.each do |inventory_unit|
          break if removed_quantity == quantity
          inventory_unit.destroy
          removed_quantity += 1
        end

        shipment.destroy if shipment.inventory_units.count == 0

        if order.completed?
          shipment.stock_location.restock variant, removed_quantity, shipment
        end

        removed_quantity
      end
  end
end
