require 'spec_helper'

describe "Orders" do
  stub_authorization!

  let(:order) { create(:order_with_line_items) }
  let(:line_item) { order.line_items.first }
  let(:bundle) { line_item.product }
  let(:parts) { (1..3).map { create(:variant) } }

  before do
    bundle.parts << [parts]
    line_item.update_attributes!(quantity: 3)
    order.reload.create_proposed_shipments
    order.finalize! 

    visit spree.edit_admin_order_path(order)
  end

  it "allows admin to edit product bundle", js: true do
    within("table.product-bundles") do
      find(".icon-edit").click
      fill_in "quantity", :with => "2"
      find(".icon-ok").click

      sleep(1) # avoid odd "cannot rollback - no transaction is active: rollback transaction"
    end
  end
end
