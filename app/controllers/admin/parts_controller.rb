class Admin::PartsController < Admin::BaseController
  helper :products
  before_filter :find_product

  def index
    @parts = @product.parts
  end

  def remove
    @part = Variant.find(params[:id])
    @product.remove_part(@part)
    render :update do |page|
      page.replace_html :product_parts, :partial => "parts_table",
                        :locals => {:parts => @product.parts}
    end
  end

  def set_count
    @part = Variant.find(params[:id])
    @product.set_part_count(@part, params[:count].to_i)
    render :update do |page|
      page.replace_html :product_parts, :partial => "parts_table",
                        :locals => {:parts => @product.parts}
    end
  end

  def available
    if params[:q].blank?
      @available_products = []
    else
      @searcher = Spree::Config.searcher_class.new({})
      @available_products =
        @searcher.send(:get_products_conditions_for, Product.not_deleted.available.can_be_part_equals(true), params[:q]) +
        Product.not_deleted.available.variants_sku_equals(params[:q]).can_be_part_equals(true) +
        Product.not_deleted.available.master_sku_equals(params[:q]).can_be_part_equals(true)

      @available_products.uniq!
    end
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def create
    @part = Variant.find(params[:part_id])
    qty = params[:part_count].to_i
    @product.add_part(@part, qty) if qty > 0
    render :update do |page|
      page.replace_html :product_parts, :partial => "parts_table",
                        :locals => {:parts => @product.parts}
      page.hide :search_hits
    end
  end

  private
    def find_product
      @product = Product.find_by_permalink(params[:product_id])
    end
end
