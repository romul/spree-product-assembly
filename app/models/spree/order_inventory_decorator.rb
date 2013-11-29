module Spree
  OrderInventory.class_eval do
    private
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

        # TODO Find a way to make it happen without overriding this method
        # from spree core
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
