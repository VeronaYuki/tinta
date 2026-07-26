# Coverage has to start before any application code is loaded, otherwise every
# line loaded earlier is reported as untested.
require "simplecov"
SimpleCov.start "rails" do
  enable_coverage :branch
  skip %r{^/spec/}
end

require "spec_helper"

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
require "shoulda/matchers"

# Shared examples, helpers and custom matchers.
Rails.root.glob("spec/support/**/*.rb").sort.each { |file| require file }

# Refuse to run against a schema that is out of date.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # Each example runs inside a transaction that is rolled back afterwards, so
  # examples never see each other's data.
  config.use_transactional_fixtures = true

  # spec/requests/*_spec.rb gets type: :request, spec/models/* gets :model, etc.
  config.infer_spec_type_from_file_location!

  # Trim Rails frames out of failure backtraces.
  config.filter_rails_from_backtrace!

  # Call create(:studio) instead of FactoryBot.create(:studio).
  config.include FactoryBot::Syntax::Methods
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
