Spree::Variant.class_eval do

  has_and_belongs_to_many  :assemblies, :class_name => "Spree::Product",
        :join_table => "spree_assemblies_parts",
        :foreign_key => "part_id", :association_foreign_key => "assembly_id"

  after_update :recalc_assemblies_price
  
  private
  
  def recalc_assemblies_price
    if Spree::ProductAssembly::Config[:auto_recalc_assemblies_price]
      assemblies.each do |assembly|
        discount = assembly.discount || Spree::ProductAssembly::Config[:default_discount_for_auto_recalc] 
        assembly.price = assembly.parts.sum(&:price) * (1-discount/100)
        assembly.save
      end
    end
  end
end
