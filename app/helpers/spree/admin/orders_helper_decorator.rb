module Spree
  module Admin
    OrdersHelper.module_eval do
      def line_item_shipment_price(line_item, quantity)
        Spree::Money.new(line_item.price * quantity, { currency: line_item.currency })
      end
    end
  end
end
