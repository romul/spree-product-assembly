module SpreeProductAssembly
  class Engine < Rails::Engine
    engine_name 'spree_product_assembly'

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      if ::Rails::Engine.subclasses.map(&:name).include? "Spree::Wombat::Engine"
        Dir.glob(File.join(File.dirname(__FILE__), "../../lib/**/*_serializer.rb")) do |serializer|
          Rails.env.production? ? require(serializer) : load(serializer)
        end
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
