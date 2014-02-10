module Spree
  module Stock
    Packer.class_eval do
      # Overriden from Spree core to build a custom package instead of the
      # default_package built in Spree
      def packages
        if splitters.empty?
          [product_assembly_package]
        else
          build_splitter.split [product_assembly_package]
        end
      end

      # Returns a package with all products from current stock location
      #
      # Follows the same logic as `Packer#default_package` except that it
      # loops through associated product parts (which is really just a
      # product / variant) to include them on the package if available.
      #
      # The product bundle itself is not included on the shipment because it
      # doesn't actually should have stock items, it's not a real product.
      # We track its parts stock items instead.
      def product_assembly_package
        package = Package.new(stock_location, order)
        order.line_items.each do |line_item|
          product = line_item.product
          if product.assembly?
            line_item.parts.each do |part|
              if part.should_track_inventory?
                next unless stock_location.stock_item(part)

                on_hand, backordered = stock_location.fill_status(part, line_item.quantity * product.count_of(part))
                package.add line_item, on_hand, :on_hand, part if on_hand > 0
                package.add line_item, backordered, :backordered, part if backordered > 0
              else
                package.add line_item, line_item.quantity * product.count_of(part), :on_hand, part
              end
            end
          elsif line_item.should_track_inventory?
            next unless stock_location.stock_item(line_item.variant)

            on_hand, backordered = stock_location.fill_status(line_item.variant, line_item.quantity)
            package.add line_item, on_hand, :on_hand, line_item.variant if on_hand > 0
            package.add line_item, backordered, :backordered, line_item.variant if backordered > 0
          else
            package.add line_item, line_item.quantity, :on_hand, line_item.variant
          end
        end
        package
      end
    end
  end
end
