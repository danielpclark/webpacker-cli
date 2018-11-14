lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'webpacker_cli/version'

Gem::Specification.new do |spec|
  spec.name          = 'webpacker_cli'
  spec.version       = WebpackerCli::VERSION
  spec.authors       = ['Daniel P. Clark']
  spec.email         = ['6ftdan@gmail.com']

  spec.summary       = %q{Bringing Webpacker to any framework.}
  spec.description   = %q{Bringing the impressive work of the Rails' Webpacker project to be available for other frameworks.}
  spec.license       = 'lgpl-3.0'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = ['webpacker-cli']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake', '>= 11.0'
  spec.add_development_dependency 'minitest', '~> 5.11'
  spec.add_development_dependency 'minitest-reporters', '~> 1.1'
  spec.add_development_dependency 'color_pound_spec_reporter', '~> 0.0.6'
  spec.add_dependency 'bundler', '~> 1.16'
  spec.add_dependency 'tty-command', '~> 0.8'
  spec.add_dependency 'webpacker', '~> 4.0.0.pre.3'
end
