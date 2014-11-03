module Spree
  module Wombat
    class AssemblyShipmentSerializer < ShipmentSerializer

      attributes :items

      def items
        i = []
        object.line_items.each do |li|
          next if li.nil?

          hsh = {
            product_id: li.variant.sku,
            name: li.name,
            quantity: li.quantity,
            price: li.price.to_f
          }

          if li.parts.present?
            bundled_items = []
            li.parts.each do |part|
              bundled_items << {
                product_id: part.sku,
                name: part.name,
                quantity: li.count_of(part),
                price: part.price.to_f
              }
            end
            hsh[:bundled_items] = bundled_items
          end
          i << hsh
        end
        i
      end
    end
  end
end
