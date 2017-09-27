# JsonapiPublisher
Use this gem to publish events as JSON API to RabbitMQ. It requires [ActiveModelSerializers](https://github.com/rails-api/active_model_serializers) with JSONAPI enabled as the adapter.

## Usage

```
routing_key = "this.is.your.standard.rabbitmq.routing.key"
object = YourActiveRecordModel.create(...)
JsonapiPublisher.publish(routing_key, object, "CREATED")
```

## Installation

choose sqs or rabbit mq with
`gem 'bunny', '~> 2.7'`
or
`gem 'aws-sdk', '~> 2'`

Add this line to your application's Gemfile:

```ruby
gem 'jsonapi_publisher'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install jsonapi_publisher
```

## Testing
Run
`docker run -p 9324:9324 lightspeedretail/fake-sqs`
`docker run -d -p 5672:5672 --name rabbitmq rabbitmq:latest`
`rake test`

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
