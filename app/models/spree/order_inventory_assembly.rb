module Spree
  # This class has basically the same functionality of Spree core OrderInventory
  # except that it takes account of bundle parts and properly creates and removes
  # inventory unit for each parts of a bundle
  class OrderInventoryAssembly < OrderInventory
    attr_reader :product

    def initialize(line_item)
      @order = line_item.order
      @line_item = line_item
      @product = line_item.product
    end

    def verify(shipment = nil)
      if order.completed? || shipment.present?
        line_item.parts.each do |part|
          existing_parts = line_item.inventory_units.where(variant: part).count
          total_parts = line_item.count_of(part) * line_item.quantity

          self.variant = part

          if existing_parts < total_parts
            shipment = determine_target_shipment unless shipment
            add_to_shipment(shipment, total_parts - existing_parts)
          elsif existing_parts > total_parts
            quantity = existing_parts - total_parts
            if shipment.present?
              remove_from_shipment(shipment, quantity)
            else
              order.shipments.each do |shipment|
                break if quantity == 0
                quantity -= remove_from_shipment(shipment, quantity)
              end
            end
          end
        end
      end
    end
  end
end
