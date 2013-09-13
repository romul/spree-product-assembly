module Spree
  Shipment.class_eval do
    # Overriden from spree core
    #
    # As line items associated with a product assembly dont have their
    # inventory units variant id equals to the line item variant id.
    # That's because we create inventory units for the parts, which are
    # actually other variants, rather than for the variant directly
    # associated with the line item (the product assembly)
    def line_items
      if order.complete? and Spree::Config[:track_inventory_levels]
        order.line_items.select { |li| inventory_units.pluck(:line_item_id).include?(li.id) }
      else
        order.line_items
      end
    end

    # Overriden from Spree core as a product bundle part should not be put
    # together with an individual product purchased (even though they're the
    # very same variant) That is so we can tell the store admin which units
    # were purchased individually and which ones as parts of the bundle
    #
    # Account for situations where we can't track the line_item for a variant.
    # This should avoid exceptions when users upgrade from spree 1.3
    def manifest
      items = []
      inventory_units.joins(:variant).includes(:variant, :line_item).group_by(&:variant).each do |variant, units|
        states = {}

        units.group_by(&:line_item).each do |line_item, units|
          units.group_by(&:state).each { |state, iu| states[state] = iu.count }
          line_item ||= order.find_line_item_by_variant(variant)

          part = line_item ? line_item.product.assembly? : false
          items << OpenStruct.new(part: part,
                                  product: line_item.try(:product),
                                  line_item: line_item,
                                  variant: variant,
                                  quantity: units.length,
                                  states: states)
        end
      end
      items
    end

    # There might be scenarios where we don't want to display every single
    # variant on the shipment. e.g. when ordering a product bundle that includes
    # 5 other parts. Frontend users should only see the product bundle as a
    # single item to ship
    def line_item_manifest
      inventory_units.includes(:line_item, :variant).group_by(&:line_item).map do |line_item, units|
        states = {}
        units.group_by(&:state).each { |state, iu| states[state] = iu.count }
        OpenStruct.new(line_item: line_item, variant: line_item.variant, quantity: units.length, states: states)
      end
    end
  end
end
