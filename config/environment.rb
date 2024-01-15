# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!
# config/environment.rb
Rails.application.configure do
    ...
    # returns error saying to add "rails_example" to config.hosts
    config.hosts << /.*\.amazonaws\.com/
    ...
    end
