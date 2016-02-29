# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'modelstack-generator-rails/version.rb'

Gem::Specification.new do |s|
  s.name        = 'modelstack-generator-rails'
  s.version     = ModelStack::Generator::Rails::VERSION
  s.authors     = ["Christoph Pageler"]
  s.email       = 'christoph.pageler@me.com'
  s.summary     = "Code generator for ModelStack"
  s.description = "ModelStack Generator for Rails Applications"
  s.homepage    = 'http://christophpageler.de'
  s.license     = 'MIT'

  s.files       =  Dir["lib/**/*"] + %w( README.md LICENSE )

  s.require_paths = ["lib"]

  s.add_dependency 'modelstack', '= 0.0.0'       # ModelStack Base
end