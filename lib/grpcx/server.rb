require 'grpc/health/checker'

module Grpcx
  module Server
    module Methods
      def initialize(opts={})
        @checker = ::Grpc::Health::Checker.new

        opts[:pool_size] ||= ENV['GRPC_SERVER_THREADS'].to_i if ENV['GRPC_SERVER_THREADS']
        opts[:max_waiting_requests] ||= ENV['GRPC_SERVER_QUEUE'].to_i if ENV['GRPC_SERVER_QUEUE']

        super(opts)

        handle(@checker)
      end

      def handle(service)
        service = service.new if service.is_a?(Class)

        # service is Ok to be marked as running, as handle is called before server actually starts handling requests:
        @checker.add_status(service.service_name, ::Grpc::Health::Checker::HealthCheckResponse::ServingStatus::SERVING)

        super(service)
      end
    end
    private_constant :Methods

    def self.append_features(mod)
      mod.prepend(Methods)
    end
  end
end
