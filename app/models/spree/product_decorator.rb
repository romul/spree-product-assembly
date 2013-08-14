Spree::Product.class_eval do
  has_and_belongs_to_many  :assemblies, :class_name => "Spree::Product",
        :join_table => "spree_assemblies_parts",
        :foreign_key => "part_id", :association_foreign_key => "assembly_id"

  has_and_belongs_to_many  :parts, :class_name => "Spree::Variant",
        :join_table => "spree_assemblies_parts",
        :foreign_key => "assembly_id", :association_foreign_key => "part_id"

  has_many :assemblies_parts, :class_name => "Spree::AssembliesPart",
    :foreign_key => "assembly_id"

  scope :individual_saled, -> { where(["spree_products.individual_sale = ?", true]) }

  scope :active, lambda { |*args|
    not_deleted.individual_saled.available(nil, args.first)
  }

  validate :assembly_cannot_be_part, :if => :assembly?

  def add_part(variant, count = 1)
    ap = Spree::AssembliesPart.get(self.id, variant.id)
    if ap
      ap.count += count
      ap.save
    else
      self.parts << variant
      set_part_count(variant, count) if count > 1
    end
  end

  def remove_part(variant)
    ap = Spree::AssembliesPart.get(self.id, variant.id)
    unless ap.nil?
      ap.count -= 1
      if ap.count > 0
        ap.save
      else
        ap.destroy
      end
    end
  end

  def set_part_count(variant, count)
    ap = Spree::AssembliesPart.get(self.id, variant.id)
    unless ap.nil?
      if count > 0
        ap.count = count
        ap.save
      else
        ap.destroy
      end
    end
  end

  def assembly?
    parts.present?
  end

  def part?
    assemblies.present?
  end

  def count_of(variant)
    ap = Spree::AssembliesPart.get(self.id, variant.id)
    ap ? ap.count : 0
  end

  def assembly_cannot_be_part
    errors.add(:can_be_part, Spree.t(:assembly_cannot_be_part)) if can_be_part
  end
end
