module Spree
  LineItem.class_eval do
    scope :assemblies, -> { joins(:product => :parts).uniq }

    def any_units_shipped?
      inventory_units.any? { |unit| unit.shipped? }
    end

    # The parts that apply to this particular LineItem. Usually `product#parts`, but
    # provided as a hook if you want to override and customize the parts for a specific
    # LineItem.
    def parts
      product.parts
    end
    
    # The number of the specified variant that make up this LineItem. By default, calls
    # `product#count_of`, but provided as a hook if you want to override and customize
    # the parts available for a specific LineItem. Note that if you only customize whether
    # a variant is included in the LineItem, and don't customize the quantity of that part
    # per LineItem, you shouldn't need to override this method.
    def count_of(variant)
      product.count_of(variant)
    end

    def quantity_by_variant
      if self.product.assembly?
        {}.tap { |hash| self.product.assemblies_parts.each { |ap| hash[ap.part] = ap.count * self.quantity } }
      else
        { self.variant => self.quantity }
      end
    end

    private
      def update_inventory
        if (changed? || target_shipment.present?) && self.order.has_checkout_step?("delivery")
          if self.product.assembly?
            OrderInventoryAssembly.new(self).verify(target_shipment)
          else
            OrderInventory.new(self.order, self).verify(target_shipment)
          end
        end
      end
  end
end
