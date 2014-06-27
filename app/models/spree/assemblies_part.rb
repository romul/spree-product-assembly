module Spree
  class AssembliesPart < ActiveRecord::Base
    belongs_to :assembly, :class_name => "Spree::Product",
      :foreign_key => "assembly_id", touch: true

    belongs_to :part, :class_name => "Spree::Variant", :foreign_key => "part_id"

    def self.get(assembly_id, part_id)
      find_or_initialize_by(assembly_id: assembly_id, part_id: part_id)
    end
  end
end
