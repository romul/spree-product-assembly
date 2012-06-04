Spree::ProductsController.class_eval do
  before_filter :verify_individual_sale

  private

    def verify_individual_sale
      return unless @product
      unless @product.individual_sale?
        raise ActiveRecord::RecordNotFound
      end
    end
end
