# TODO: this interceptor is kind of easily testable,
#       worth having a test in future.

module Grpcx
  module Server
    module Interceptor
      module ActiveSupport
        module Notifications
          # Instruments each request with ActiveSupport::Notifications.
          class Instrument < GRPC::ServerInterceptor
            METRIC_NAME = 'process_action.grpc'.freeze

            def bidi_streamer(_requests: nil, _call: nil, meth: nil, &block)
              # TODO: at some point would be nice to wrap streamers and report stats like messages received/sent
              wrap(action: meth, &block)
            end

            def client_streamer(_call: nil, meth: nil, &block)
              # TODO: at some point would be nice to wrap streamers and report stats like messages received
              wrap(action: meth, &block)
            end

            def request_response(_request: nil, _call: nil, meth: nil, &block)
              wrap(action: meth, &block)
            end

            def server_streamer(_request: nil, _call: nil, meth: nil, &block)
              # TODO: at some point would be nice to wrap streamers and report stats like messages sent
              wrap(action: meth, &block)
            end

            private

            def wrap(opts={}, &block)
              ActiveSupport::Notifications.instrument(METRIC_NAME, opts, &block)
            end

          end
        end
      end
    end
  end
end
