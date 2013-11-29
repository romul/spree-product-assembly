module Spree
  module Stock
    Coordinator.class_eval do
      private
        # TODO Make an application config called stock_prioritizer within spree
        def prioritize_packages(packages)
          AssemblyPrioritizer.new(order, packages).prioritized_packages
        end
    end
  end
end
