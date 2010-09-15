# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class ProductAssemblyExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/product_assembly"

  # Please use product_assembly/config/routes.rb instead for extension routes.

  def self.require_gems(config)
    #config.gem 'composite_primary_keys', :lib => false
  end

  def activate

    Product.class_eval do

      has_and_belongs_to_many  :assemblies, :class_name => "Product",
            :join_table => "assemblies_parts",
            :foreign_key => "part_id", :association_foreign_key => "assembly_id"

      has_and_belongs_to_many  :parts, :class_name => "Variant",
            :join_table => "assemblies_parts",
            :foreign_key => "assembly_id", :association_foreign_key => "part_id"


      named_scope :individual_saled, {
        :conditions => ["products.individual_sale = ?", true]
      }

      named_scope :active, lambda { |*args|
        not_deleted.individual_saled.available(args.first).scope(:find)
      }


      alias_method :orig_on_hand, :on_hand
      # returns the number of inventory units "on_hand" for this product
      def on_hand
        if self.assembly? && Spree::Config[:track_inventory_levels]
          parts.map{|v| v.on_hand / self.count_of(v) }.min
        else
          self.orig_on_hand
        end
      end

      alias_method :orig_on_hand=, :on_hand=
      def on_hand=(new_level)
        self.orig_on_hand=(new_level) unless self.assembly?
      end

      alias_method :orig_has_stock?, :has_stock?
      def has_stock?
        if self.assembly? && Spree::Config[:track_inventory_levels]
          !parts.detect{|v| self.count_of(v) > v.on_hand}
        else
          self.orig_has_stock?
        end
      end

      def add_part(variant, count = 1)
        ap = AssembliesPart.get(self.id, variant.id)
        unless ap.nil?
          ap.count += count
          ap.save
        else
          self.parts << variant
          set_part_count(variant, count) if count > 1
        end
      end

      def remove_part(variant)
        ap = AssembliesPart.get(self.id, variant.id)
        unless ap.nil?
          ap.count -= 1
          if ap.count > 0
            ap.save
          else
            ap.destroy
          end
        end
      end

      def set_part_count(variant, count)
        ap = AssembliesPart.get(self.id, variant.id)
        unless ap.nil?
          if count > 0
            ap.count = count
            ap.save
          else
            ap.destroy
          end
        end
      end

      def assembly?
        parts.present?
      end

      def part?
        assemblies.present?
      end

      def count_of(variant)
        ap = AssembliesPart.get(self.id, variant.id)
        ap ? ap.count : 0
      end

    end

    InventoryUnit.class_eval do
      def self.sell_units(order)
        # we should not already have inventory associated with the order at this point but we should clear to be safe (#1394)
        order.inventory_units.destroy_all

        out_of_stock_items = []
        order.line_items.each do |line_item|
          variant = line_item.variant
          quantity = line_item.quantity
          product = variant.product

          if product.assembly?
            product.parts.each do |v|
              out_of_stock_items += create_units(order, v, quantity * product.count_of(v))
            end
          else
            out_of_stock_items += create_units(order, variant, quantity)
          end
        end
        out_of_stock_items.flatten
      end

      def self.adjust_units(order)
        units_by_variant = order.inventory_units.group_by(&:variant_id)
        out_of_stock_items = []

        #check line items quantities match
        order.line_items.each do |line_item|
          if line_item.variant.product.assembly?

            line_item.variant.product.parts.each do |variant|
              quantity = line_item.quantity
              unit_count = units_by_variant.key?(variant.id) ? units_by_variant[variant.id].size : 0

              adjust_line(variant, quantity, unit_count, order, out_of_stock_items, units_by_variant)

              #remove it from hash as it's up-to-date
              units_by_variant.delete(variant.id)
            end

          else
            variant = line_item.variant
            quantity = line_item.quantity
            unit_count = units_by_variant.key?(variant.id) ? units_by_variant[variant.id].size : 0

            adjust_line(variant, quantity, unit_count, order, out_of_stock_items, units_by_variant)

            #remove it from hash as it's up-to-date
            units_by_variant.delete(variant.id)
          end

        end

        #check for deleted line items (if theres anything left in units_by_variant its' extra)
        units_by_variant.each do |variant_id, units|
          units.each {|unit| unit.restock!}
        end

        out_of_stock_items
      end

      private
        def self.adjust_line(variant, quantity, unit_count, order, out_of_stock_items, units_by_variant)
          if unit_count < quantity
            out_of_stock_items.concat create_units(order, variant, (quantity - unit_count))
          elsif  unit_count > quantity
            (unit_count - quantity).times do
              inventory_unit = units_by_variant[variant.id].pop
              inventory_unit.restock!
            end
          end
        end
    end


    LineItem.class_eval do
      def validate
        unless quantity && quantity >= 0
          errors.add(:quantity, I18n.t("validation.must_be_non_negative"))
        end
        # avoid reload of order.inventory_units by using direct lookup
        unless !Spree::Config[:track_inventory_levels]                        ||
               Spree::Config[:allow_backorders]                               ||
               order   && InventoryUnit.order_id_equals(order).first.present? ||
               variant && quantity <= variant.on_hand
          errors.add(:quantity, I18n.t("validation.is_too_large") + " (#{self.variant.name})")
        end

        return unless variant

        if variant.product.assembly?
          variant.product.parts.each do |part|
            if shipped_count = order.shipped_units.nil? ? nil : order.shipped_units[part]
              errors.add(:quantity, I18n.t("validation.cannot_be_less_than_shipped_units") ) if quantity < shipped_count
            end
          end
        else
          if shipped_count = order.shipped_units.nil? ? nil : order.shipped_units[variant]
            errors.add(:quantity, I18n.t("validation.cannot_be_less_than_shipped_units") ) if quantity < shipped_count
          end
        end
      end

    end
  end
end


