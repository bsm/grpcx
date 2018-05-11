require 'active_support/notifications'
require 'grpclb/server'

module Grpcx
  class Server < Grpclb::Server
    module Interceptors
      # Instruments each request with ActiveSupport::Notifications.instrument
      # with 'process_action.grpc' metric name.
      # Adds `action: GRPC_METHOD_NAME` data to notification payload.
      class Instrumentation < GRPC::ServerInterceptor
        METRIC_NAME = 'process_action.grpc'.freeze

        def request_response(opts={}, &block)
          instrument(action: opts[:method], &block)
        end

        def client_streamer(opts={}, &block)
          instrument(action: opts[:method], &block)
        end

        def server_streamer(opts={}, &block)
          instrument(action: opts[:method], &block)
        end

        def bidi_streamer(opts={}, &block)
          instrument(action: opts[:method], &block)
        end

        private

        def instrument(opts={}, &block)
          ActiveSupport::Notifications.instrument(METRIC_NAME, opts, &block)
        end

      end
    end
  end
end
