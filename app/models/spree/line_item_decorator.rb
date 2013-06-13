module Spree
  LineItem.class_eval do
    scope :assemblies, -> { joins(:product => :parts) }
  end
end
