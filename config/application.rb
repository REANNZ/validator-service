# frozen_string_literal: true
require_relative 'boot'

require 'rails/all'
require 'torba/rails'

Bundler.require(*Rails.groups)

module ValidatorService
  class Application < Rails::Application
    config.autoload_paths << Rails.root.join('lib')

    config.shib_rack.receiver = 'Authentication::SubjectReceiver'
    config.shib_rack.error_handler = 'Authentication::ErrorHandler'
  end
end
