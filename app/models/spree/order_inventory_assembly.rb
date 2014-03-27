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
      parts_total = line_item.parts.to_a.sum {|v| line_item.count_of(v)}

      if inventory_units.size < (parts_total * line_item.quantity)

        line_item.parts.each do |part|
          quantity = (line_item.count_of(part) * (line_item.quantity - line_item.changed_attributes['quantity'].to_i))

          self.variant = part
          shipment = determine_target_shipment unless shipment
          add_to_shipment(shipment, quantity)
        end
      elsif inventory_units.size > (parts_total * line_item.quantity)
        remove(shipment)
      end
    end

    private
      def remove(shipment = nil)
        line_item.parts.each do |part|
          quantity = (line_item.count_of(part) * (line_item.changed_attributes['quantity'] - line_item.quantity))

          self.variant = part
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
