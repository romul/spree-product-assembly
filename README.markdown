# Product Assembly

[![Build Status](https://secure.travis-ci.org/spree/spree-product-assembly.png)](https://travis-ci.org/spree/spree-product-assembly)
[![Code Climate](https://codeclimate.com/github/spree/spree-product-assembly.png)](https://codeclimate.com/github/spree/spree-product-assembly)

Create a product which is composed of other products.

## Installation

Add the following line to your `Gemfile`
```ruby
gem 'spree_product_assembly', github: 'spree/spree-product-assembly', branch: 'master'
```

Run bundle install as well as the extension intall command to copy and run migrations and
append spree_product_assembly to your js manifest file

    bundle install
    rails g spree_product_assembly:install

_master branch is compatible with spree edge and rails 4 only. Please use
2-0-stable for Spree 2.0.x or 1-3-stable branch for Spree 1.3.x compatibility_

_In case you're upgrading from 1-3-stable of this extension you might want to run a
rake task which assigns a line item to your previous inventory units from bundle
products. That is so you have a better view on the current backend UI and avoid
exceptions. No need to run this task if you're not upgrading from product assembly
1-3-stable_

    rake spree_product_assembly:upgrade

## Use

To build a bundle (assembly product) you'd need to first check the "Can be part"
flag on each product you want to be part of the bundle. Then create a product
and add parts to it. By doing that you're making that product an assembly.

The store will treat assemblies a bit different than regular products on checkout.
Spree will create and track inventory units for its parts rather than for the product itself.
That means you essentially have a product composed of other products. From a
customer perspective it's like they are paying a single amount for a collection
of products.

Contributing
------------

Spree is an open source project and we encourage contributions. Please see the [contributors guidelines][1] before contributing.

In the spirit of [free software][2], **everyone** is encouraged to help improve this project.

Here are some ways *you* can contribute:

* by using prerelease versions
* by reporting [bugs][3]
* by suggesting new features
* by writing translations
* by writing or editing documentation
* by writing specifications
* by writing code (*no patch is too small*: fix typos, add comments, clean up inconsistent whitespace)
* by refactoring code
* by resolving [issues][3]
* by reviewing patches

Starting point:

* Fork the repo
* Clone your repo
* Run `bundle install`
* Run `bundle exec rake test_app` to create the test application in `spec/test_app`
* Make your changes
* Ensure specs pass by running `bundle exec rspec spec`
* Submit your pull request

Copyright (c) 2014 [Spree Commerce Inc.][4] and [contributors][5], released under the [New BSD License][6]

[1]: http://guides.spreecommerce.com/developer/contributing.html
[2]: http://www.fsf.org/licensing/essays/free-sw.html
[3]: https://github.com/spree/spree-product-assembly/issues
[4]: https://github.com/spree
[5]: https://github.com/spree/spree-product-assembly/graphs/contributors
[6]: https://github.com/spree/spree-product-assembly/blob/master/LICENSE.md

