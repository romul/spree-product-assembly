module Spree
  CheckoutController.class_eval do
    # Override because we don't want to remove unshippable items from the order
    # A bundle itself is an unshippable item
    def before_payment; end
  end
end
