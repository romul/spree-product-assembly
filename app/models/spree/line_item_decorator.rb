module Spree
  LineItem.class_eval do
    scope :assemblies, -> { joins(:product => :parts).uniq }

    private
      def update_inventory
        if self.product.assembly? && order.completed?
          OrderInventoryAssembly.new(self).verify(target_shipment)
        else
          OrderInventory.new(self.order).verify(self, target_shipment)
        end
      end
  end
end
