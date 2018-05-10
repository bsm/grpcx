module Grpcx
  module Server
    module Interceptors
      # Manages ActiveRecord::Base connection,
      # making sure that connection is established before each request
      # and re-pooling connections when request is processed.
      class ActiveRecord < GRPC::ServerInterceptor

        def bidi_streamer(_requests: nil, _call: nil, _method: nil, &block)
          wrap(&block)
        end

        def client_streamer(_call: nil, _method: nil, &block)
          wrap(&block)
        end

        def request_response(_request: nil, _call: nil, _method: nil, &block)
          wrap(&block)
        end

        def server_streamer(_request: nil, _call: nil, _method: nil, &block)
          wrap(&block)
        end

        private

        def wrap
          ::ActiveRecord::Base.establish_connection unless ::ActiveRecord::Base.connection.active?
          yield
        ensure
          ::ActiveRecord::Base.clear_active_connections!
        end

      end
    end
  end
end
