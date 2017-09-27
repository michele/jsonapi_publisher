begin
  require 'bunny'
  require 'aws-sdk'
rescue
end
require 'active_record'

module JsonapiPublisher
  class Configuration
    attr_accessor :qservice

    def initialize
      @qservice = nil
    end
  end

  class << self
    attr_writer :configuration
    attr_accessor :connection, :channel

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end

  def self.publish(routing_key, message = {}, event = '')
    if message.is_a?(ActiveRecord::Base)
      message = ActiveModelSerializers::SerializableResource.new(message).as_json
    end
    if event.present?
      message = { event: event }.merge(message)
    end
    if configuration.qservice == 'rmq'
      x = channel.topic(ENV['EVENT_TOPIC'] || 'events')
      x.publish(message.to_json, routing_key: routing_key)
    elsif configuration.qservice == 'sqs'
      message_attributes = { routing_key: { string_value: routing_key, data_type: 'String' } }
      connection.send_message(queue_url: ENV['QUEUE_URL'] || channel.queue_url, message_body: message.to_json, message_attributes: message_attributes)
    end
  end

  def self.channel
    if configuration.qservice == 'rmq'
      @channel ||= connection.create_channel
    elsif configuration.qservice == 'sqs'
      @channel ||= connection.create_queue({
        queue_name: ENV['EVENT_TOPIC'],
        attributes: {
          "FifoQueue" => "true"
        }
      })
    end
  end

  def self.connection
    if configuration.qservice == 'rmq'
      @connection ||= Bunny.new(host: ENV['RABBITMQ_HOST'] || 'localhost', user: ENV['RABBITMQ_USER'] || 'guest', pass: ENV['RABBITMQ_PASS'] || 'guest').tap do |c|
        c.start
      end
    elsif configuration.qservice == 'sqs'
      @connection ||= Aws::SQS::Client.new(endpoint: ENV['AWS_SQS_ENDPOINT'], region: ENV['AWS_REGION'], secret_access_key: ENV['AWS_ACCESS_KEY_ID'], access_key_id: ENV['AWS_SECRET_ACCESS_KEY'])
    end
  end

  def self.reset_connection
    self.connection = nil
    self.channel = nil
    configuration.qservice = nil
  end
end
