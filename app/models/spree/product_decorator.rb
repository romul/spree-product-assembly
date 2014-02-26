Spree::Product.class_eval do
  has_and_belongs_to_many  :parts, :class_name => "Spree::Variant",
        :join_table => "spree_assemblies_parts",
        :foreign_key => "assembly_id", :association_foreign_key => "part_id"

  has_many :assemblies_parts, :class_name => "Spree::AssembliesPart",
    :foreign_key => "assembly_id"

  scope :individual_saled, -> { where(individual_sale: true) }

  scope :search_can_be_part, ->(query){ not_deleted.available.joins(:master)
    .where(arel_table["name"].matches("%#{query}%").or(Spree::Variant.arel_table["sku"].matches("%#{query}%")))
    .where(can_be_part: true)
    .limit(30)
  }

  after_update :check_auto_assembly_price
  validate :assembly_cannot_be_part, :if => :assembly?

  def add_part(variant, count = 1)
    set_part_count(variant, count_of(variant) + count)
  end

  def remove_part(variant)
    set_part_count(variant, 0)
  end

  def set_part_count(variant, count)
    ap = assemblies_part(variant)
    if count > 0
      ap.count = count
      ap.save
    else
      ap.destroy
    end
    reload
  end

  def assembly?
    parts.present?
  end

  def count_of(variant)
    ap = assemblies_part(variant)
    # This checks persisted because the default count is 1
    ap.persisted? ? ap.count : 0
  end

  def assembly_cannot_be_part
    errors.add(:can_be_part, Spree.t(:assembly_cannot_be_part)) if can_be_part
  end

  def recalculate_assembly_price
    my_discount = discount || Spree::ProductAssembly::Config[:default_discount_for_auto_recalc] 
    part_total = parts.includes(:default_price).map do |part|
      part.default_price.amount * count_of(part)
    end.sum

    price = master.default_price
    price_amount = part_total * (1-my_discount/100)
    status = price.update_attribute(:amount, price_amount)
    self.index if defined? Sunspot
    status
  end

  def check_auto_assembly_price
    return unless (assembly? and discount_changed?)

    recalculate_assembly_price
  end

  private
  def assemblies_part(variant)
    Spree::AssembliesPart.get(self.id, variant.id)
  end
end
