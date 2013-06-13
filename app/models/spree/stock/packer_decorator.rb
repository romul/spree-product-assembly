module Spree
  module Stock
    Packer.class_eval do
      # Overriden from Spree core to build a custom package instead of the
      # default_package built in Spree
      def packages
        build_splitter.split [product_assembly_package]
      end

      # Returns a package with all products and parts from current stock location
      #
      # Follows the same logic as `Packer#default_package` except that it
      # loops through associated product parts (which is really just a
      # product / variant) to include them on the package if available.
      #
      # The product bundle itself is not included on the shipment because it
      # doesn't actually should have stock items. We track its parts stock items
      # instead.
      def product_assembly_package
        package = Package.new(stock_location, order)
        order.line_items.each do |line_item|
          product = line_item.product
          if product.assembly?
            product.parts.each do |part|
              next unless stock_location.stock_item(part)

              on_hand, backordered = stock_location.fill_status(part, line_item.quantity * product.count_of(part))
              package.add part, on_hand, :on_hand if on_hand > 0
              package.add part, backordered, :backordered if backordered > 0
            end
          else
            next unless stock_location.stock_item(line_item.variant)

            on_hand, backordered = stock_location.fill_status(line_item.variant, line_item.quantity)
            package.add line_item.variant, on_hand, :on_hand if on_hand > 0
            package.add line_item.variant, backordered, :backordered if backordered > 0
          end
        end
        package
      end
    end
  end
end
