module Spree
  module Stock
    Package.class_eval do
      ContentItem = Struct.new(:variant, :quantity, :state, :line_item)

      def add(variant, quantity, state=:on_hand, line_item = nil)
        contents << ContentItem.new(variant, quantity, state, line_item)
      end

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
