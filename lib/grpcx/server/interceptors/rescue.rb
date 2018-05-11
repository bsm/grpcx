require 'grpclb/server'

module Grpcx
  class Server < Grpclb::Server
    module Interceptors
      # Delegates exception handling to provided rescuable.
      class Rescue < GRPC::ServerInterceptor

        def initialize(rescuable, opts={})
          @rescuable = rescuable
          super(opts)
        end

        def request_response(*)
          yield
        rescue StandardError => err
          @rescuable.rescue_with_handler(err) || raise
        end

        def client_streamer(*)
          yield
        rescue StandardError => err
          @rescuable.rescue_with_handler(err) || raise
        end

        def server_streamer(*)
          yield
        rescue StandardError => err
          @rescuable.rescue_with_handler(err) || raise
        end

        def bidi_streamer(*)
          yield
        rescue StandardError => err
          @rescuable.rescue_with_handler(err) || raise
        end

      end
    end
  end
end
