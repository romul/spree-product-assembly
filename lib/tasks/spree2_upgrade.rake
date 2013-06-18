namespace :spree_product_assembly do
  desc 'Link legacy inventory units to an order line item'
  task :upgrade => :environment do
    shipments = Spree::Shipment.includes(:inventory_units).where("spree_inventory_units.line_item_id IS NULL")

    shipments.each do |shipment|
      shipment.inventory_units.includes(:variant).group_by(&:variant).each do |variant, units|

        line_item = shipment.order.line_items.detect { |line_item| line_item.variant_id == variant.id }

        unless line_item

          begin
            master = shipment.order.products.detect { |p| variant.assemblies.include? p }.master
            supposed_line_item = shipment.order.line_items.detect { |line_item| line_item.variant_id == master.id }

            if supposed_line_item
              Spree::InventoryUnit.where(id: units.map(&:id)).update_all "line_item_id = #{supposed_line_item.id}"
            else
              puts "Couldn't find a matching line item for #{variant.name}"
            end
          rescue
            puts "Couldn't find a matching line item for #{variant.name}"
          end
        end
      end
    end
  end
end
