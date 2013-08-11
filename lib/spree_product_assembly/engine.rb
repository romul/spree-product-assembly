module SpreeProductAssembly
  class Engine < Rails::Engine
    engine_name 'spree_product_assembly'
    
    initializer "spree.advanced_cart.environment", :before => :load_config_initializers do |app|
      Spree::ProductAssembly::Config = Spree::ProductAssemblyConfiguration.new
    end

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
