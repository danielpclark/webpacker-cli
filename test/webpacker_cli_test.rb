require 'test_helper'

class WebpackerCliTest < Minitest::Test
  attr_reader :dir
  def setup
    @dir = Dir.mktmpdir
    Dir.chdir(@dir)
  end

  def test_files_are_created
    WebpackerCli.init(dir: dir)
    WebpackerCli::FILE_MANIFEST.each do |file|
      assert File.exist?("#{dir}/#{file}"), "File '#{file}' doesn't exist!"
    end
  end

  def test_files_are_created_with_executable
    TTY::Command.new(color: false, uuid: false).
      run("#{WebpackerCli.executable} init")
    WebpackerCli::FILE_MANIFEST.each do |file|
      assert File.exist?("#{dir}/#{file}"), "File '#{file}' doesn't exist!"
    end
  end
end
