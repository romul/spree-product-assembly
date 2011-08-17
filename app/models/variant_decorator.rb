Variant.class_eval do

  has_and_belongs_to_many  :assemblies, :class_name => "Product",
        :join_table => "assemblies_parts",
        :foreign_key => "part_id", :association_foreign_key => "assembly_id"

end
