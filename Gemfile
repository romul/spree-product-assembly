source "https://rubygems.org"

gemspec

spree = ENV['SPREE'] || '2-0-stable'

gem 'spree', github: 'spree/spree', branch: spree

gem 'pry-rails'

group :assets do
  gem 'coffee-rails', '~> 3.2.2'
  gem 'sass-rails', '~> 3.2.6'
end

group :test do
  gem 'capybara', '~> 2.1.0'
  gem 'selenium-webdriver', '~> 2.32.0'
end
