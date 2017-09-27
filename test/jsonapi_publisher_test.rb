# require 'test_helper'
require 'minitest/autorun'
require 'minitest/hooks/default'
require 'jsonapi_publisher'
require 'pry'
require 'faker'
require 'bunny'
require 'aws-sdk'

ENV['AWS_ACCESS_KEY_ID'] = 'x'
ENV['AWS_SECRET_ACCESS_KEY'] = 'x'
ENV['AWS_REGION'] = 'piripiri'
ENV['AWS_SQS_ENDPOINT'] = 'http://localhost:9324'
ENV['EVENT_TOPIC'] = 'events'
ENV['QUEUE_URL'] = "http://localhost:9324/queue/#{ENV['EVENT_TOPIC']}"

class JsonapiPublisher::Test < ActiveSupport::TestCase
  test 'truth' do
    assert_kind_of Module, JsonapiPublisher
  end

  describe 'sqs connection' do
    before(:all) do
      JsonapiPublisher.reset_connection
      JsonapiPublisher.configure do |config|
        config.qservice = 'sqs'
      end
      # Clean all messages
      if JsonapiPublisher.connection.list_queues.queue_urls.length > 1
        resp = JsonapiPublisher.connection.receive_message({
          queue_url: ENV['QUEUE_URL'],
          max_number_of_messages: 10
        })
        resp.messages.each do |message|
          JsonapiPublisher.connection.delete_message({
            queue_url: ENV['QUEUE_URL'],
            receipt_handle: message.receipt_handle
          })
        end
      end
    end

    it 'has a valid connection' do
      assert_equal Aws::SQS::Client, JsonapiPublisher.connection.class
    end

    it 'has a valid channell' do
      assert_equal Seahorse::Client::Response, JsonapiPublisher.channel.class
    end

    it 'has a valid queue url' do
      assert_match /http/, JsonapiPublisher.channel.queue_url
    end

    describe 'sending a message' do
      before(:all) do
        @routing_key = Faker::Internet.slug.gsub('_', '.')
        @body = {iam:{a: 'message'}}
        @event = Faker::Lorem.word.upcase
        @message = JsonapiPublisher.publish(@routing_key, @body, @event)
      end
      it 'returns a valid message response class' do
        assert_equal Seahorse::Client::Response, @message.class
        assert_equal Aws::SQS::Types::SendMessageResult, @message.data.class
      end
      it 'really send a message' do
        resp = JsonapiPublisher.connection.receive_message({
          queue_url: ENV['QUEUE_URL'],
          max_number_of_messages: 10
        })
        assert_equal({ event: @event }.merge(@body).to_json, resp.messages[0].body)
        assert_equal @routing_key, resp.messages[0].message_attributes["routing_key"].string_value
      end
    end
  end

  describe 'rmq connection' do
    before(:all) do
      JsonapiPublisher.reset_connection
      JsonapiPublisher.configure do |config|
        config.qservice = 'rmq'
      end
    end
    it 'has a valid connection' do
      assert_equal Bunny::Session, JsonapiPublisher.connection.class
    end
    it 'has a valid channel' do
      assert_equal Bunny::Channel, JsonapiPublisher.channel.class
    end
  end

  describe 'reset connection' do
    before(:all) { JsonapiPublisher.reset_connection }
    it 'reset connection if requested' do
      assert_equal NilClass, JsonapiPublisher.connection.class
    end
  end
end
