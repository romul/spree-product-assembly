module Spree
  module Admin
    LineItemsController.class_eval do
      def update
        @line_item.update_attributes(line_item_params)
        render nothing: true
      end

      def destroy
        @line_item.destroy_along_with_units
        render nothing: true
      end

      private
        def line_item_params
          params.require(:line_item).permit(permitted_line_item_attributes)
        end
    end
  end
end
