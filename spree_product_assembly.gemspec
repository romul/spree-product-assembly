Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_product_assembly'
  s.version     = '2.2.0.beta'
  s.summary     = 'Adds oportunity to make bundle of products to your Spree store'
  s.description = s.summary
  s.required_ruby_version = '>= 1.9.3'

  s.author            = 'Roman Smirnov'
  s.email             = 'roman@railsdog.com'
  s.homepage          = 'https://github.com/spree/spree-product-assembly'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_backend', '~> 2.4.0'
  s.add_dependency 'active_model_serializers', '0.9.0.alpha1'

  s.add_development_dependency 'rspec-rails', '~> 3.1.0'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'factory_girl', '~> 4.4'
  s.add_development_dependency 'coffee-rails', '~> 4.0.0'
  s.add_development_dependency 'sass-rails', '~> 4.0.0'
  s.add_development_dependency 'capybara', '~> 2.4'
  s.add_development_dependency 'poltergeist', '1.5.0'
  s.add_development_dependency 'database_cleaner', '~> 1.3'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'pg'
end
