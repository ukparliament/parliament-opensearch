require 'simplecov'
require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
                                                                   Coveralls::SimpleCov::Formatter,
                                                                   SimpleCov::Formatter::HTMLFormatter
                                                               ])
SimpleCov.start do
  add_filter '/spec/'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'parliament'
require 'parliament/open_search'

require 'webmock'
require 'webmock/rspec'
require 'vcr'

require 'timecop'

WebMock.disable_net_connect!(allow_localhost: true)

# Setup the initial description file request

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock # or :fakeweb
  config.configure_rspec_metadata!

  # Dynamically filter our sensitive information
  config.filter_sensitive_data('<AUTH_TOKEN>') { ENV['OPENSEARCH_AUTH_TOKEN'] }
  config.filter_sensitive_data('http://localhost:3030') { ENV['OPENSEARCH_DESCRIPTION_URL'] }
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed

  config.after(:each) do
    Parliament::OpenSearch::DescriptionCache.instance_variable_set(:@store, nil)
  end
end
