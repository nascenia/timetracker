# Initialize the application configuration
CONFIG = YAML.load_file("#{Rails.root.to_s}/config/application.yml")[Rails.env]

# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Internal::Application.initialize!
