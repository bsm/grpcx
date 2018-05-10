module Grpcx
  module Server
    module Interceptors
      # Manages ActiveRecord::Base connection,
      # making sure that connection is established before each request
      # and re-pooling connections when request is processed.
      class ActiveRecord < GRPC::ServerInterceptor

        def request_response(*, &block)
          wrap(&block)
        end

        def client_streamer(*, &block)
          wrap(&block)
        end

        def server_streamer(*, &block)
          wrap(&block)
        end

        def bidi_streamer(*, &block)
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
