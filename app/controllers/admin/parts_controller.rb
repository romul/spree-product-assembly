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
  
  def available
    if params[:q].blank?
      @available_products = []
    else
      @available_products = Product.find(:all, 
        :conditions => ['lower(name) LIKE ? AND can_be_part = ?', "%#{params[:q].downcase}%", true])
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
      @product_admin_tabs << { :name => "Parts", :url => "admin_product_parts_url" }
    end  
end
