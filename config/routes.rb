Spree::Core::Engine.add_routes do

  namespace :admin do
    resources :products do
      resources :parts do
        member do
          post :select
          post :remove
          post :set_count
        end
        collection do
          post :available
          get  :selected
        end
      end
    end
  end

end
