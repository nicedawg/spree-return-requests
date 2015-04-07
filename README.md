SpreeReturnRequests
===================

Allow customers to create Return Authorization requests which can be approved by Spree Admins

Installation
------------

Add spree_return_requests to your Gemfile:

```ruby
gem 'spree_return_requests'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_return_requests:install
```

You may want to schedule the periodic expiration of old, stale authorized
Return Authorizations which were never marked as received. 
  * Make sure your settings provide a suitable window for the customer to send
    in their return and have it marked as received.
  * Make sure you communicate that window to your customers.
  * And then schedule the periodic purging of old, stale authorized Return
    Authorizations by calling ```Spree::ReturnAuthorization.cancel_authorized_and_expired``` using your favorite scheduled jobs mechanism.

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

```shell
bundle
bundle exec rake test_app
bundle exec rspec spec
```

When testing your applications integration with this extension you may use its factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_return_requests/factories'
```

Copyright (c) 2013 Hitcents, released under the New BSD License
