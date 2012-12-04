class Spree::AssembliesPart < ActiveRecord::Base
  belongs_to :assembly, :class_name => "Spree::Product", :foreign_key => "assembly_id"
  belongs_to :part, :class_name => "Spree::Variant", :foreign_key => "part_id"

  def self.get(assembly_id, part_id)
    Spree::AssembliesPart.find_by_assembly_id_and_part_id(assembly_id, part_id)
  end

  def save
    Spree::AssembliesPart.update_all("count = #{count}", 
        ["assembly_id = ? AND part_id = ?", assembly_id, part_id])
  end

  def destroy
    Spree::AssembliesPart.delete_all(["assembly_id = ? AND part_id = ?", assembly_id, part_id])
  end

end
