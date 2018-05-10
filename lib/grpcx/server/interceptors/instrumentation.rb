require 'active_support/notifications'

module Grpcx
  module Server
    module Interceptors
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
