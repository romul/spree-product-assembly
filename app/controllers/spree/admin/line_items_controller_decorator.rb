module Spree
  module Admin
    LineItemsController.class_eval do
      def update
        @line_item.update_attributes(params[:line_item])
        render nothing: true
      end

      def destroy
        @line_item.destroy_along_with_units
        render nothing: true
      end
    end
  end
end
