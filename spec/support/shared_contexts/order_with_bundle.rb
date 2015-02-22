shared_context "product is ordered as individual and within a bundle" do
  let(:order) { create(:order_with_line_items) }
  let(:parts) { (1..3).map { create(:variant) } }

  let(:bundle_variant) { order.variants.first }
  let(:bundle) { bundle_variant.product }

  let(:common_product) { order.variants.last }

  before do
    bundle.parts << [parts, common_product]
  end
end
