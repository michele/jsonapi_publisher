require 'active_record'
require 'configuration'

module JsonapiPublisher
  class << self
    attr_writer :configuration
    attr_accessor :connection, :channel
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.publish(routing_key, message = {}, event = '')
    if message.is_a?(ActiveRecord::Base)
      message = ActiveModelSerializers::SerializableResource.new(message).as_json
    end
    message = { event: event }.merge(message) if event.present?
    if configuration.qservice == 'rmq'
      x = channel.topic(ENV['EVENT_TOPIC'] || 'events')
      x.publish(message.to_json, routing_key: routing_key)
    elsif configuration.qservice == 'sqs'
      message_attributes = { routing_key: { string_value: routing_key, data_type: 'String' } }
      if configuration.avoid_send
        p; p "Requesting with queue_url: #{ENV['QUEUE_URL'] || channel.queue_url}, message_body: #{message.to_json}, message_attributes: #{message_attributes}"
      else
        connection.send_message(queue_url: ENV['QUEUE_URL'] || channel.queue_url, message_body: message.to_json, message_attributes: message_attributes)
      end
    end
  end

  def self.channel
    if configuration.qservice == 'rmq'
      @channel ||= connection.create_channel
    elsif configuration.qservice == 'sqs'
      @channel ||= connection.get_queue_url(queue_name: ENV['EVENT_TOPIC'] || 'events')
    end
  end

  def self.connection
    if configuration.qservice == 'rmq'
      @connection ||= Bunny.new(host: ENV['RABBITMQ_HOST'] || 'localhost', user: ENV['RABBITMQ_USER'] || 'guest', pass: ENV['RABBITMQ_PASS'] || 'guest').tap(&:start)
    elsif configuration.qservice == 'sqs'
      options = {
        region: ENV['AWS_REGION'] || 'eu-west-1'
      }
      options[:endpoint] = ENV['AWS_SQS_ENDPOINT'] if ENV['AWS_SQS_ENDPOINT']
      options[:access_key_id] = ENV['AWS_ACCESS_KEY_ID'] if ENV['AWS_ACCESS_KEY_ID']
      options[:access_key_id] = ENV['AWS_SECRET_ACCESS_KEY'] if ENV['AWS_SECRET_ACCESS_KEY']
      @connection ||= Aws::SQS::Client.new(options)
    end
  end

  def self.reset_connection
    self.connection = nil
    self.channel = nil
    configuration.qservice = nil
  end
end
