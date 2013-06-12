module Spree
  OrderPopulator.class_eval do
    private
      # Overriden from Spree core to make it also check for assembly stocks
      def check_stock_levels(variant, quantity)
        display_name = %Q{#{variant.name}}
        display_name += %Q{ (#{variant.options_text})} unless variant.options_text.blank?

        if check_assembly_stock_levels(variant, quantity)
          true
        else
          errors.add(:base, Spree.t(:out_of_stock, :scope => :order_populator, :item => display_name.inspect))
          return false
        end
      end

      def check_assembly_stock_levels(variant, quantity)
        product = variant.product

        if product.assembly?
          product.parts.all? do |part|
            Stock::Quantifier.new(part).can_supply? quantity
          end
        else
          Stock::Quantifier.new(variant).can_supply? quantity
        end
      end
  end
end
