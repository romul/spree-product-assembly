# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class ProductAssemblyExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/product_assembly"

  # Please use product_assembly/config/routes.rb instead for extension routes.

  def self.require_gems(config)
    config.gem 'composite_primary_keys', :lib => 'composite_primary_keys'
    require 'composite_primary_keys'
  end
  
  def activate
    
    Admin::ProductsController.class_eval do
      before_filter :add_parts_tab
      private
      def add_parts_tab
        @product_admin_tabs << { :name => "Parts", :url => "admin_product_parts_url" }
      end
    end
    
    Product.class_eval do

      has_and_belongs_to_many  :assemblies, :class_name => "Product",
            :join_table => "assemblies_parts",
            :foreign_key => "part_id", :association_foreign_key => "assembly_id"

      has_and_belongs_to_many  :parts, :class_name => "Variant",
            :join_table => "assemblies_parts",
            :foreign_key => "assembly_id", :association_foreign_key => "part_id"


      def add_part(variant, count = 1)
        begin
          ap = AssembliesPart.find(self.id, variant.id)        
          ap.count += count
          ap.save
        rescue
          self.parts << variant
          set_part_count(variant, count) if count > 1
        end        
      end
      
      def remove_part(variant)
        begin
          ap = AssembliesPart.find(self.id, variant.id)        
          ap.count -= 1
          if ap.count > 0
            ap.save
          else
            ap.destroy
          end
        rescue
        end        
      end
      
      def set_part_count(variant, count)
        begin
          ap = AssembliesPart.find(self.id, variant.id)
          if count > 0        
            ap.count = count
            ap.save
          else
            ap.destroy  
          end
        rescue
        end         
      end

      def assembly?
        parts.present?
      end
      
      def part?
        assemblies.present?
      end
      
      def count_of(variant)
        begin
          ap = AssembliesPart.find(self.id, variant.id)        
          ap.count
        rescue
          1
        end         
      end

    end
    
  end
end
