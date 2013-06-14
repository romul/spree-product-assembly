module Spree
  Shipment.class_eval do
    def manifest
      inventory_units.group_by(&:line_item).map do |line_item, units|
        states = {}
        units.group_by(&:state).each { |state, iu| states[state] = iu.count }
        OpenStruct.new(line_item: line_item, variant: line_item.variant, quantity: units.length, states: states)
      end
    end
  end
end
