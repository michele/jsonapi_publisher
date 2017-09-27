$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'jsonapi_publisher/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'jsonapi_publisher'
  s.version     = JsonapiPublisher::VERSION
  s.authors     = ['Michele Finotto']
  s.email       = ['m@finotto.org']
  s.homepage    = 'https://github.com/michele/jsonapi_publisher'
  s.summary     = 'Use this gem to publish JSON API events to RabbitMQ.'
  s.description = 'Use this gem to publish JSON API events to RabbitMQ.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '>= 4.2'
  s.add_dependency 'active_model_serializers', '~> 0.10'
  s.add_development_dependency 'bunny'
  s.add_development_dependency 'aws-sdk'
  s.add_development_dependency 'minitest-hooks'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'faker'
end
