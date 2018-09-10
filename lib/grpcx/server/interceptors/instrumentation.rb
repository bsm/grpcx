require 'active_support/notifications'

module Grpcx
  module Server
    module Interceptors
      class Instrumentation < GRPC::ServerInterceptor
        METRIC_NAME = 'process_action.grpc'.freeze

        def request_response(opts={}, &block)
          instrument(opts[:method], &block)
        end

        def client_streamer(opts={}, &block)
          instrument(opts[:method], &block)
        end

        def server_streamer(opts={}, &block)
          instrument(opts[:method], &block)
        end

        def bidi_streamer(opts={}, &block)
          instrument(opts[:method], &block)
        end

        private

        def instrument(method, &block)
          service = method.owner.service_name # method is just a standard ruby Method class, so `owner` is a service impl
          action = method.name # does not match real proto service name; it's a GRPC::GenericService.underscore-d version
          ActiveSupport::Notifications.instrument(METRIC_NAME, service: service, action: action, &block)
        end

      end
    end
  end
end
