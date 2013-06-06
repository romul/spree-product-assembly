Spree::LineItem.class_eval do
  validate :validate_quantity_and_stock

  private
    def validate_quantity_and_stock
      unless quantity && quantity >= 0
        errors.add(:quantity, I18n.t("validation.must_be_non_negative"))
      end

      # avoid reload of order.inventory_units by using direct lookup
      unless !Spree::Config[:track_inventory_levels] || quantity > variant_stock_on_hand
        errors.add(:quantity, I18n.t("validation.is_too_large") + " (#{self.variant.name})")
      end
    end

    def variant_stock_on_hand
      variant.stock_items.sum(&:count_on_hand)
    end
end
