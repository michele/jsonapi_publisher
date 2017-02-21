require "bunny"
require "active_record"

module JsonapiPublisher
  def self.publish(routing_key, message = {}, event="")
    if message.is_a?(ActiveRecord::Base)
      message = ActiveModelSerializers::SerializableResource.new(message).as_json
    end
    if event.present?
      message = {event: event}.merge(message)
    end
    x = channel.topic(ENV['EVENT_TOPIC'] || 'events')
    x.publish(message.to_json, routing_key: routing_key)
  end

  def self.channel
    @channel ||= connection.create_channel
  end

  def self.connection
    @connection ||= Bunny.new(host: ENV['RABBITMQ_HOST'] || 'localhost', user: ENV['RABBITMQ_USER'] || 'guest', pass: ENV['RABBITMQ_PASS'] || 'guest').tap do |c|
      c.start
    end
  end
end
