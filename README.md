# JsonapiPublisher
Use this gem to publish events as JSON API to RabbitMQ. It requires [ActiveModelSerializers](https://github.com/rails-api/active_model_serializers) with JSONAPI enabled as the adapter.

## Usage

```
routing_key = "this.is.your.standard.rabbitmq.routing.key"
object = YourActiveRecordModel.create(...)
JsonapiPublisher.publish(routing_key, object, "CREATED")
```

## Installation
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

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
