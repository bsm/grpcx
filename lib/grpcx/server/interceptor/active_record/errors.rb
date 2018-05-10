module Grpcx
  module Server
    module Interceptor
      module ActiveRecord
        # Intercepts most common ActiveRecord::ActiveRecordError-s
        # and transforms them into corresponding GRPC::BadStatus ones.
        class Errors < GRPC::ServerInterceptor

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
            yield
          rescue ActiveRecord::RecordInvalid => e
            raise GRPC::InvalidArgument.new(errors: e.record.errors.to_h)
          rescue ActiveRecord::RecordNotFound => e
            raise GRPC::NotFound.new(id: e.id, model: e.model.to_s)
          end

        end
      end
    end
  end
end
