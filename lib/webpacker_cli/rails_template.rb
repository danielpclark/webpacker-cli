module WebpackerCli
  module RailsTemplate
    class << self
      def gemfile(test = false)
        %Q$source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/\#{repo}.git" }

gem 'rake', '>= 11'
gem 'webpacker_cli', '#{WebpackerCli::VERSION}'#{
  if test; ", path: '#{File.expand_path('../', __dir__)}'" end
}
$ + gemspec_deps
      end

      def rakefile
        %q$require_relative "config/application"

Rails.application.load_tasks$
      end

      def config_application
        %q$require "action_controller/railtie"
require "action_view/railtie"
require "webpacker"

module TestApp
  class Application < ::Rails::Application
    config.secret_key_base = "abcdef"
    config.eager_load = true
    config.webpacker.check_yarn_integrity = false
  end
end$
      end

      def bin_rails
        %q$#!/usr/bin/env ruby
APP_PATH = File.expand_path('../config/application', __dir__)
require 'rails/commands'$
      end

      def gemspec_deps
        $LOAD_PATH << File.expand_path('../', __dir__)
        specs = eval File.read(File.expand_path("../../webpacker_cli.gemspec", __dir__))
        specs.runtime_dependencies.
          map {|i| "gem '#{i.name}', '#{i.requirement.requirements.join(' ')}'"}.
          join("\n")
      end
    end
  end
end

