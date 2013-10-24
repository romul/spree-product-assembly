module Spree
  LineItem.class_eval do
    scope :assemblies, -> { joins(:product => :parts).uniq }

    has_many :inventory_units

    def any_units_shipped?
      OrderInventoryAssembly.new(self).inventory_units.any? do |unit|
        unit.shipped?
      end
    end

    # Destroy and verify inventory so that units are restocked back to the
    # stock location
    def destroy_along_with_units
      self.quantity = 0
      OrderInventoryAssembly.new(self).verify
      self.destroy
    end

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
