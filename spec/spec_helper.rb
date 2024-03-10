# frozen_string_literal: true

require 'byebug'
require "philosophy"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require 'pathname'
def pgn(name) = Pathname.new(__dir__).join('fixtures').join("#{name}.pgn").read
