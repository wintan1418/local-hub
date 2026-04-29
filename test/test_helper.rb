ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Generated fixtures are incomplete in this app; focused tests create the
    # records they need so the suite is not coupled to placeholder YAML data.

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
