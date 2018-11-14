$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'webpacker_cli'

ENV['WEBPACKER_CLI'] = 'TEST'

require 'minitest/autorun'
require 'color_pound_spec_reporter'

Minitest::Reporters.use! [ColorPoundSpecReporter.new]

Minitest.after_run { ENV.delete('WEBPACKER_CLI') }
