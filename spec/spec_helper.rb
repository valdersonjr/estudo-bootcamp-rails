RSpec.configure do |config|

  config.before(:each) do
    # Set the queue adapter to :test before each example
    ActiveJob::Base.queue_adapter = :test
  end
  
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
