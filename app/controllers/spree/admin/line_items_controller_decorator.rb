module Spree
  module Admin
    LineItemsController.class_eval do
      def update
        @line_item.update_attributes(params[:line_item])
        respond_to do |format|
          format.js
        end
      end
    end
  end
end
