require 'test_helper'
require 'open3'

class WebpackerCliTest < Minitest::Test
  EXE = File.expand_path('../bin/webpacker-cli', __dir__)

  def in_tmp
    Dir.mktmpdir { |dir| yield dir }
  end

  def quietly
    out = $stdout
    $stdout = StringIO.new
    yield
  ensure
    $stdout = out
  end

  def test_files_are_created
    in_tmp do |dir|
      quietly { WebpackerCli.init(dir: dir, install: false) }
      WebpackerCli::FILE_MANIFEST.each do |file|
        assert File.exist?(File.join(dir, file)), "File '#{file}' doesn't exist!"
      end
    end
  end

  def test_init_keeps_existing_files_unless_forced
    in_tmp do |dir|
      quietly { WebpackerCli.init(dir: dir, install: false) }
      File.write(File.join(dir, 'config/webpacker.yml'), 'custom')
      quietly { WebpackerCli.init(dir: dir, install: false) }
      assert_equal 'custom', File.read(File.join(dir, 'config/webpacker.yml'))
      quietly { WebpackerCli.init(dir: dir, install: false, force: true) }
      refute_equal 'custom', File.read(File.join(dir, 'config/webpacker.yml'))
    end
  end

  def test_settings_merge_environment
    in_tmp do |dir|
      quietly { WebpackerCli.init(dir: dir, install: false) }
      assert_equal 'packs', WebpackerCli.settings(dir, 'production')['public_output_path']
    end
  end

  def test_check_reports_missing_packages
    in_tmp do |dir|
      quietly { WebpackerCli.init(dir: dir, install: false) }
      assert(WebpackerCli.check(dir: dir).any? { |p| p =~ /not installed/ })
    end
  end

  def test_executable_init
    in_tmp do |dir|
      _, status = Open3.capture2e(EXE, 'init', '--skip-install', chdir: dir)
      assert status.success?
      assert File.exist?(File.join(dir, 'package.json'))
    end
  end

  def test_cli_help_and_version
    out, status = Open3.capture2e(EXE, '--help')
    assert status.success?
    assert_match(/Usage: webpacker-cli/, out)
    out, = Open3.capture2e(EXE, 'version')
    assert_equal WebpackerCli::VERSION, out.strip
  end

  # Full round trip against the real npm registry; skipped when unavailable.
  def test_compile_end_to_end
    skip 'set WEBPACKER_CLI_E2E=1 to run' unless ENV['WEBPACKER_CLI_E2E']
    in_tmp do |dir|
      out, status = Open3.capture2e(EXE, 'init', chdir: dir)
      assert status.success?, out
      out, status = Open3.capture2e({ 'NODE_ENV' => 'production' }, EXE, 'compile', chdir: dir)
      assert status.success?, out
      manifest = JSON.parse(File.read(File.join(dir, 'public/packs/manifest.json')))
      assert_match %r{\A/packs/application-\w+\.js\z}, manifest['application.js']
      assert File.exist?(File.join(dir, 'public', manifest['application.js']))
    end
  end
end
