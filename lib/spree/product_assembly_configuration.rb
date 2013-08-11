module Spree
  class ProductAssemblyConfiguration < Preferences::Configuration
    preference :auto_recalc_assemblies_price, :boolean, :default => false
    preference :default_discount_for_auto_recalc, :decimal, :default => 10.0
  end
end
