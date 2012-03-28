unless ENV['travis']
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec"
    #add_filter "/features"
  end
end

require 'rspec'
require 'vcr'
require 'webmock'
require 'squeegee'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/vcr_cassettes'
  c.hook_into :webmock
  c.filter_sensitive_data('<SURNAME>') { ENV['surname'] }
  c.filter_sensitive_data('<FORENAME>') { ENV['forename'] }
  c.filter_sensitive_data('<POSTCODE>') { ENV['address_postcode'] }
  c.filter_sensitive_data('<ADDRESS>') { ENV['address_road'] }
  c.filter_sensitive_data('<BRITISH GAS ACCOUNT NUMBER>') { ENV['british_gas_account_number'] }
  c.filter_sensitive_data('<BSKYB ACCOUNT NUMBER>') { ENV['bskyb_account_number'] }

end

CONFIGS = YAML::load(File.open('spec/support/configs.yml'))

RSpec.configure do |config|
  config.order = :rand
  config.color_enabled = true

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  config.before(:each) do
  end
end
