module Spree
  Shipment.class_eval do
    def manifest
      inventory_units.includes(:line_item, :variant).group_by(&:line_item).map do |line_item, units|
        states = {}
        units.group_by(&:state).each { |state, iu| states[state] = iu.count }
        OpenStruct.new(line_item: line_item, variant: line_item.variant, quantity: units.length, states: states)
      end
    end

    def variant_manifest
      items = []
      inventory_units.includes(:variant, :line_item).group_by(&:variant).each do |variant, units|
        states = {}

        units.group_by(&:line_item).each do |line_item, units|
          units.group_by(&:state).each { |state, iu| states[state] = iu.count }
          part = line_item.product.assembly?
          items << OpenStruct.new(part: part,
                                  product: line_item.product,
                                  line_item: line_item,
                                  variant: variant,
                                  quantity: units.length,
                                  states: states)
        end
      end
      items
    end
  end
end
