Spree::Price.class_eval do
  after_update :recalc_assemblies_price

  private
  
  def recalc_assemblies_price
    return unless amount_changed?
    return unless Spree::ProductAssembly::Config[:auto_recalc_assemblies_price]

    variant.assemblies.each(&:recalculate_assembly_price)
  end
end