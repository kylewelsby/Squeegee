# Squeegee [![CI Build Status](https://secure.travis-ci.org/BritRuby/Squeegee.png?branch=master)][travis] [![Dependency Status](https://gemnasium.com/BritRuby/Squeegee.png?travis)][gemnasium]

[travis]:http://travis-ci.org/BritRuby/Squeegee
[gemnasium]:https://gemnasium.com/BritRuby/Squeegee

Squeegee is a collection of login strategies to gather bill dates and amounts
from customer accounts.

## Installation

Add this line to your application's Gemfile:

    gem 'squeegee'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install squeegee

## Usage

Get the next bill statement for British Gas

    user_credentials = {
      :username => "JoeBlogs",
      :password => "superduper",
      :customer_number => "8500xxxxxxx"
    }

    s = Squeegee::BritishGas.new(user_credentials)

    s.accounts.first #=> { :due_at => "2012-03-23",
                           :amount => 10000,
                         }



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
