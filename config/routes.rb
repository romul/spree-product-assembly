# Put your extension routes here.

map.namespace :admin do |admin|
    admin.resources :products, :member => {:clone => :get}, :has_many => [:product_properties, :images] do |product|
      product.resources :variants
      product.resources :option_types, :member => { :select => :get, :remove => :get}, :collection => {:available => :get, :selected => :get}
      product.resources :taxons, :member => {:select => :post, :remove => :post}, :collection => {:available => :post, :selected => :get}
      product.resources :parts, :member => {:select => :post, :remove => :post}, :collection => {:available => :post, :selected => :get}
    end
end  
