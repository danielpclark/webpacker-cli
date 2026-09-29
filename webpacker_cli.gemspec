lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'webpacker_cli/version'

Gem::Specification.new do |spec|
  spec.name                   = 'webpacker_cli'
  spec.version                = WebpackerCli::VERSION
  spec.authors                = ['Daniel P. Clark']
  spec.email                  = ['6ftdan@gmail.com']

  spec.summary                = %q{Bringing Webpacker to any framework.}
  spec.description            = %q{Webpacker's conventions (webpacker.yml, packs, manifest.json) for any framework, powered by Webpack 5 and without Rails.}
  spec.license                = 'LGPL-3.0-only'
  spec.homepage               = 'https://github.com/danielpclark/webpacker-cli'
  spec.required_ruby_version  = '>= 3.0'
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri']   = "#{spec.homepage}/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files                  = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|\.github)/}) }
  end
  spec.bindir                 = 'bin'
  spec.executables            = ['webpacker-cli']
  spec.require_paths          = ['lib']

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'minitest', '~> 5.11'
end
