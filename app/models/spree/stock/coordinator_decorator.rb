module Spree
  module Stock
    Coordinator.class_eval do
      private
        def prioritize_packages(packages)
          AssemblyPrioritizer.new(order, packages).prioritized_packages
        end
    end
  end
end
