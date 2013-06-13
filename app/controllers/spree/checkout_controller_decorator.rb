module Spree
  CheckoutController.class_eval do
    def before_payment; end
  end
end
