module Spree
  OrderInventory.class_eval do
    # Only verify inventory for completed orders
    # as carts have inventory assigned via create_proposed_shipment methh
    #
    # or when shipment is explicitly passed
    def verify(line_item, shipment = nil)
      if order.completed? || shipment.present?

        if line_item.product.assembly?
          variant_units = inventory_units_for_bundle(line_item)
          parts_total = line_item.product.assemblies_parts.sum(&:count)
          product = line_item.product

          if variant_units.size < (parts_total * line_item.quantity)

            product.parts.each do |part|
              quantity = (product.count_of(part) * (line_item.quantity - line_item.changed_attributes['quantity']))

              shipment = determine_target_shipment(part) unless shipment
              add_to_shipment(shipment, part, quantity, line_item)
            end
          elsif variant_units.size > (parts_total * line_item.quantity)
            remove_bundle_units(line_item, variant_units, shipment)
          end

        else
          variant_units = inventory_units_for(line_item.variant, line_item)

          if variant_units.size < line_item.quantity
            quantity = line_item.quantity - variant_units.size

            shipment = determine_target_shipment(line_item.variant) unless shipment
            add_to_shipment(shipment, line_item.variant, quantity)
          elsif variant_units.size > line_item.quantity
            remove(line_item, variant_units, shipment)
          end
        end
      else
        true
      end
    end

    def inventory_units_for_bundle(line_item = nil)
      units = order.shipments.collect { |s| s.inventory_units.all }.flatten
      units.group_by(&:line_item)[line_item.id] || []
    end

    private
      def remove_bundle_units(line_item, variant_units, shipment = nil)
        product = line_item.product

        product.parts.each do |part|
          quantity = (product.count_of(part) * (line_item.changed_attributes['quantity'] - line_item.quantity))

          if shipment.present?
            remove_from_shipment(shipment, part, quantity)
          else
            order.shipments.each do |shipment|
              break if quantity == 0
              quantity -= remove_from_shipment(shipment, part, quantity)
            end
          end
        end
      end

      # create inventory_units
      # adding to this shipment, and removing from stock_location
      # return quantity added
      def add_to_shipment(shipment, variant, quantity, line_item)
        on_hand, back_order = shipment.stock_location.fill_status(variant, quantity)

        on_hand.times do
          shipment.inventory_units.create({line_item: line_item, variant: variant, state: 'on_hand'}, without_protection: true)
        end

        back_order.times do
          shipment.inventory_units.create({line_item: line_item, variant: variant, state: 'backordered'}, without_protection: true)
        end

        shipment.stock_location.unstock variant, quantity, shipment
        quantity
      end
  end
end
