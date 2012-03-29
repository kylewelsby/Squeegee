unless ENV['travis']
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec"
  end
end

require 'rspec'
require 'webmock'
require 'squeegee'

CONFIGS = YAML::load(File.open('spec/support/configs.yml'))

RSpec.configure do |config|
  config.order = :rand
  config.color_enabled = true

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  config.before(:each) do
  end
end
