module Grpcx
  module Server
    module Interceptors
      class Rescue < GRPC::ServerInterceptor
        def initialize(rescuable)
          @rescuable = rescuable
        end

        def bidi_streamer(*)
          yield
        rescue => exception
          @rescuable.rescue_with_handler(exception) || raise
        end

        def client_streamer(*)
          yield
        rescue => exception
          @rescuable.rescue_with_handler(exception) || raise
        end

        def request_response(*)
          yield
        rescue => exception
          @rescuable.rescue_with_handler(exception) || raise
        end

        def server_streamer(*)
          yield
        rescue => exception
          @rescuable.rescue_with_handler(exception) || raise
        end

      end
    end
  end
end
