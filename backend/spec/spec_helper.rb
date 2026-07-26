# Framework configuration that does not need Rails. Loaded by rails_helper.rb.
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # Fail if we stub a method the real object does not have — keeps doubles
    # honest when the implementation changes underneath them.
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Run only the examples tagged :focus when any of them exist.
  config.filter_run_when_matching :focus

  # Require the RSpec.describe form instead of the bare describe monkey patch.
  config.disable_monkey_patching!

  # Random order surfaces hidden dependencies between examples.
  config.order = :random
  Kernel.srand config.seed
end
