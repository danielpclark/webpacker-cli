require 'webpacker_cli/version'
require 'webpacker_cli/rails_template'
require 'fileutils'
require 'tty/command'
require 'bundler'

module WebpackerCli
  FILE_MANIFEST = %w[
    bin
    bin/rails
    config
    config/application.rb
    config/webpack/development.js
    config/webpack/environment.js
    config/webpack/loaders
    config/webpack/production.js
    config/webpack/test.js
    Gemfile
    Rakefile
  ]

  class << self
    def init(**opts)
      dir = opts.fetch(:dir) { Dir.pwd }
      test = opts.fetch(:test) { !!ENV['WEBPACKER_CLI'].to_s['TEST'] }

      Dir.chdir(dir) do
        File.open('Gemfile', 'w') {|file|
          file.write(WebpackerCli::RailsTemplate.gemfile(test))
        }
        File.open('Rakefile', 'w') {|file| file.write(WebpackerCli::RailsTemplate.rakefile) }

        FileUtils.mkdir_p('bin')
        File.open('bin/rails', 'w') {|file| file.write(WebpackerCli::RailsTemplate.bin_rails) }

        FileUtils.mkdir_p('config/webpack/loaders')
        File.open('config/application.rb', 'w') {|file| file.write(WebpackerCli::RailsTemplate.config_application) }

        env = {
          BUNDLE_GEMFILE: "#{dir}/Gemfile"
        }

        if test
          env.update( {
            GEM_HOME: ENV["GEM_HOME"],
            GEM_PATH: ENV["GEM_PATH"],
          })
        end

        bundler_env(test) do
          TTY::Command.
            new(color: false, uuid: false).
            run(env, 'bundle install', chdir: dir)

          TTY::Command.
            new(color: false, uuid: false).
            run(env, "bundle exec #{executable} install", chdir: dir)
        end
      end
    end

    def bundler_env(test)
      if test
        Bundler.with_clean_env { yield }
      else
        yield
      end
    end

    def executable
      begin
        Gem.bin_path("webpacker-cli", "webpacker-cli")
      rescue
        File.expand_path('../bin/webpacker-cli', __dir__)
      end
    end
  end
end
