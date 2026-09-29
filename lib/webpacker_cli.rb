require 'fileutils'
require 'json'
require 'open3'
require 'yaml'
require 'webpacker_cli/version'

# webpacker-cli: Webpacker's conventions (webpacker.yml, app/javascript/packs,
# public/packs/manifest.json) for any framework, without Rails.
#
# Ruby only scaffolds the project and launches Webpack; the Webpack setup itself
# is a plain JavaScript config generated into the project so it can be updated
# independently of this gem.
module WebpackerCli
  class Error < StandardError; end

  TEMPLATE_DIR = File.expand_path('webpacker_cli/templates', __dir__)

  # Generated file => template it is copied from.
  TEMPLATES = {
    'config/webpacker.yml'            => 'webpacker.yml',
    'config/webpack/webpack.config.js' => 'webpack.config.js',
    'app/javascript/packs/application.js' => 'application.js',
    'package.json'                    => 'package.json'
  }.freeze

  FILE_MANIFEST = (%w[config config/webpack app/javascript app/javascript/packs] + TEMPLATES.keys).freeze

  WEBPACK_CONFIG = 'config/webpack/webpack.config.js'.freeze

  class << self
    # Scaffold a project.  Existing files are kept unless force: true.
    def init(dir: Dir.pwd, force: false, install: true, **)
      dir = File.expand_path(dir)
      FileUtils.mkdir_p(dir)

      TEMPLATES.each do |dest, template|
        path = File.join(dir, dest)
        if File.exist?(path) && !force
          puts "   exist  #{dest}"
          next
        end
        FileUtils.mkdir_p(File.dirname(path))
        FileUtils.cp(File.join(TEMPLATE_DIR, template), path)
        puts "  create  #{dest}"
      end

      install_packages(dir) if install
      dir
    end

    def install_packages(dir)
      manager = package_manager(dir)
      run(dir, {}, manager, 'install')
    end

    def compile(dir: Dir.pwd, env: current_env)
      webpack(dir, env)
    end

    def watch(dir: Dir.pwd, env: current_env)
      webpack(dir, env, '--watch')
    end

    # Remove compiled packs and the Webpack cache.
    def clobber(dir: Dir.pwd, env: current_env)
      cfg = settings(dir, env)
      [File.join(cfg['public_root_path'], cfg['public_output_path']), cfg['cache_path']].each do |rel|
        FileUtils.rm_rf(File.join(dir, rel))
        puts "  remove  #{rel}"
      end
    end

    # Verify prerequisites, returning a list of problems (empty when healthy).
    def check(dir: Dir.pwd)
      problems = []
      problems << 'Node.js was not found in PATH' unless which('node')
      problems << 'Neither yarn nor npm was found in PATH' unless which('yarn') || which('npm')
      problems << "Missing #{WEBPACK_CONFIG}; run `webpacker-cli init`" unless File.exist?(File.join(dir, WEBPACK_CONFIG))
      unless File.exist?(File.join(dir, 'node_modules', '.bin', 'webpack'))
        problems << 'Node packages are not installed; run `webpacker-cli init` or install them yourself'
      end
      problems
    end

    def info(dir: Dir.pwd)
      {
        'webpacker-cli' => VERSION,
        'ruby'          => RUBY_VERSION,
        'node'          => capture('node', '--version', dir: dir),
        'package manager' => "#{package_manager(dir)} #{capture(package_manager(dir), '--version', dir: dir)}",
        'webpack'       => webpack_version(dir)
      }
    end

    def current_env
      ENV['WEBPACKER_ENV'] || ENV['NODE_ENV'] || ENV['RAILS_ENV'] || 'development'
    end

    # Merged `default` + environment section of config/webpacker.yml.
    def settings(dir, env = current_env)
      file = File.join(dir, 'config', 'webpacker.yml')
      raise Error, "Missing config/webpacker.yml; run `webpacker-cli init`" unless File.exist?(file)
      all = YAML.safe_load(File.read(file), aliases: true) || {}
      (all['default'] || {}).merge(all[env] || {})
    end

    def package_manager(dir)
      return 'npm' if File.exist?(File.join(dir, 'package-lock.json')) && !File.exist?(File.join(dir, 'yarn.lock'))
      return 'yarn' if File.exist?(File.join(dir, 'yarn.lock')) || which('yarn')
      'npm'
    end

    # Path of the webpacker-cli executable (kept for integrations such as webpacker-rs).
    def executable
      Gem.bin_path('webpacker_cli', 'webpacker-cli')
    rescue StandardError
      File.expand_path('../bin/webpacker-cli', __dir__)
    end

    private

    def webpack(dir, env, *args)
      problems = check(dir: dir)
      raise Error, problems.join("\n") unless problems.empty?
      run(dir, { 'NODE_ENV' => env, 'WEBPACKER_ENV' => env },
          'node_modules/.bin/webpack', '--config', WEBPACK_CONFIG, *args)
    end

    def run(dir, env, *cmd)
      success = system(env, *cmd, chdir: dir)
      raise Error, "Command failed: #{cmd.join(' ')}" unless success
      true
    rescue Errno::ENOENT
      raise Error, "Command not found: #{cmd.first}"
    end

    def webpack_version(dir)
      JSON.parse(File.read(File.join(dir, 'node_modules', 'webpack', 'package.json')))['version']
    rescue StandardError
      'not found'
    end

    def capture(*cmd, dir:)
      out, status = Open3.capture2e(*cmd, chdir: dir)
      status.success? ? out.strip : 'not found'
    rescue Errno::ENOENT
      'not found'
    end

    def which(cmd)
      ENV['PATH'].to_s.split(File::PATH_SEPARATOR).any? do |p|
        f = File.join(p, cmd)
        File.executable?(f) && !File.directory?(f)
      end
    end
  end
end
