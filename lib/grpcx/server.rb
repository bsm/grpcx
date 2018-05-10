require 'grpc/health/checker'

require 'grpcx/server/interceptor/active_record/errors'
require 'grpcx/server/interceptor/active_record/connection'
require 'grpcx/server/interceptor/active_support/notifications/instrument'

module Grpcx
  module Server
    module Methods
      def initialize(opts={})
        @checker = ::Grpc::Health::Checker.new
        super(apply_default_options(opts))
        handle(@checker)
      end

      def handle(service)
        service = service.new if service.is_a?(Class)

        # service is Ok to be marked as running, as handle is called before server actually starts handling requests:
        @checker.add_status(service.service_name, ::Grpc::Health::Checker::HealthCheckResponse::ServingStatus::SERVING)

        super(service)
      end

      private

      def apply_default_options(opts={})
        opts.tap do
          opts[:pool_size] ||= ENV['GRPC_SERVER_THREADS'].to_i if ENV['GRPC_SERVER_THREADS']
          opts[:max_waiting_requests] ||= ENV['GRPC_SERVER_QUEUE'].to_i if ENV['GRPC_SERVER_QUEUE']

          # interceptors are fired in FIFO order,
          # so more generic handlers come last:
          (opts[:interceptors] ||= []).concat(default_interceptors)
        end
      end

      def default_interceptors
        # this could be a const array, as we don't rely on any options to init interceptors (yet),
        # but it's fine to leave as-is for now:
        [
          Grpcx::Server::Interceptor::ActiveRecord::Errors.new,
          Grpcx::Server::Interceptor::ActiveRecord::Connection.new,
          Grpcx::Server::Interceptor::ActiveSupport::Notifications::Instrument.new,
        ]
      end
    end
    private_constant :Methods

    def self.append_features(mod)
      mod.prepend(Methods)
    end
  end
end
