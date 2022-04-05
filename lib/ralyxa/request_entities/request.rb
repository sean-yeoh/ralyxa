require 'json'
require 'forwardable'
require 'alexa_verifier'
require_relative './user'

module Ralyxa
  module RequestEntities
    class Request
      extend Forwardable
      INTENT_REQUEST_TYPE = 'IntentRequest'.freeze
      CAN_FULFILL_INTENT_REQUEST_TYPE = 'CanFulfillIntentRequest'.freeze

      def_delegator :@user, :id, :user_id
      def_delegator :@user, :access_token, :user_access_token
      def_delegator :@user, :access_token_exists?, :user_access_token_exists?

      attr_reader :request

      def initialize(original_request, user_class = Ralyxa::RequestEntities::User)
        validate_request(original_request) if Ralyxa.configuration.validate_requests?

        @request = JSON.parse(original_request.body.read)
        attempt_to_rewind_request_body(original_request)

        @user = user_class.build(@request)
      end

      def intent_name
        if intent_request? || can_fulfill_intent_request?
          @request['request']['intent']['name']
        else
          @request['request']['type']
        end
      end

      def slot_value(slot_name)
        @request['request']['intent']['slots'][slot_name]['value']
      end

      def new_session?
        @request['session']['new']
      end

      def session_attributes
        @request['session']['attributes']
      end

      def session_attribute(attribute_name)
        session_attributes[attribute_name]
      end

      def system_attributes
        @request['context']['System']
      end

      def supported_interfaces
        if interfaces = system_attributes.dig('device', 'supportedInterfaces')
          interfaces.keys
        else
          []
        end
      end

      def apl_touch_event_arguments
        @request['request']['arguments']
      end

      private

      def intent_request?
        @request['request']['type'] == INTENT_REQUEST_TYPE
      end

      def can_fulfill_intent_request?
        @request['request']['type'] == CAN_FULFILL_INTENT_REQUEST_TYPE
      end

      def validate_request(request)
        AlexaVerifier.valid!(request)
      end

      def attempt_to_rewind_request_body(original_request)
        original_request.body&.rewind
      end
    end
  end
end
