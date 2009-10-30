class AssembliesPart < ActiveRecord::Base
	set_primary_keys :assembly_id, :part_id
	belongs_to :assembly, :class_name => "Product", :foreign_key => "assembly_id"
	belongs_to :part, :class_name => "Variant", :foreign_key => "part_id"
end
