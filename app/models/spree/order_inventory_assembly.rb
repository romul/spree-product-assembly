module Spree
  # This class has basically the same functionality of Spree core OrderInventory
  # except that it takes account of bundle parts and properly creates and removes
  # inventory unit for each parts of a bundle
  #
  # TODO A lot of code here could be removed to avoid duplicated logic once we
  # improve spree core OrderInventory API. Then we could just inherit from
  # that class and only override what's needed for the specs of this extension
  # e.g. `verify`, `inventory_units` and `remove`
  class OrderInventoryAssembly
    attr_reader :order, :line_item, :product

    def initialize(line_item)
      @order = line_item.order
      @line_item = line_item
      @product = line_item.product
    end

    def verify(shipment = nil)
      parts_total = product.assemblies_parts.sum(&:count)

      if inventory_units.size < (parts_total * line_item.quantity)

        product.parts.each do |part|
          quantity = (product.count_of(part) * (line_item.quantity - line_item.changed_attributes['quantity']))

          shipment = determine_target_shipment(part) unless shipment
          add_to_shipment(shipment, part, quantity)
        end
      elsif inventory_units.size > (parts_total * line_item.quantity)
        remove(shipment)
      end
    end

    def inventory_units
      units = order.shipments.collect { |s| s.inventory_units.all }.flatten
      @inventory_units ||= units.group_by(&:line_item_id)[line_item.id] || []
    end

    private
      def remove(shipment = nil)
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

      # Returns either one of the shipment
      #
      # first unshipped that already includes this variant
      # first unshipped that's leaving from a stock_location that stocks this variant
      def determine_target_shipment(variant)
        shipment = order.shipments.detect do |shipment|
          (shipment.ready? || shipment.pending?) && shipment.include?(variant)
        end

        shipment ||= order.shipments.detect do |shipment|
          (shipment.ready? || shipment.pending?) && variant.stock_location_ids.include?(shipment.stock_location_id)
        end
      end

      # Create inventory_units for the shipment and remove items from stock
      # Returns quantity added
      def add_to_shipment(shipment, variant, quantity)
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

      # Returns quantity removed
      def remove_from_shipment(shipment, variant, quantity)
        return 0 if quantity == 0 || shipment.shipped?

        shipment_units = shipment.inventory_units_for(variant).reject do |variant_unit|
          variant_unit.state == 'shipped'
        end.sort_by(&:state)

        removed_quantity = 0

        shipment_units.each do |inventory_unit|
          break if removed_quantity == quantity
          inventory_unit.destroy
          removed_quantity += 1
        end

        shipment.destroy if shipment.inventory_units.count == 0

        # removing this from shipment, and adding to stock_location
        shipment.stock_location.restock variant, removed_quantity, shipment
        removed_quantity
      end
  end
end
