require 'grpc'
require 'grpc/health/checker'
require 'active_support/concern'
require 'active_support/rescuable'
require 'grpcx/server/interceptors'

module Grpcx
  module Server
    extend ActiveSupport::Concern
    include ActiveSupport::Rescuable

    ServingStatus = ::Grpc::Health::Checker::HealthCheckResponse::ServingStatus

    included do
      attr_reader :interceptors

      rescue_from 'ActiveRecord::RecordInvalid' do |e|
        raise GRPC::InvalidArgument.new('record invalid', errors: e.record.errors.to_h)
      end
      rescue_from 'ActiveRecord::RecordNotFound' do |e|
        raise GRPC::NotFound.new('record not found', id: e.id, model: e.model.to_s)
      end
    end

    def initialize(opts={})
      opts[:pool_size] ||= ENV['GRPC_SERVER_THREADS'].to_i if ENV['GRPC_SERVER_THREADS']
      opts[:max_waiting_requests] ||= ENV['GRPC_SERVER_QUEUE'].to_i if ENV['GRPC_SERVER_QUEUE']

      # interceptors are fired in FIFO order.
      opts[:interceptors] ||= []
      opts[:interceptors].prepend Grpcx::Server::Interceptors::Rescue.new(self)
      opts[:interceptors].prepend Grpcx::Server::Interceptors::Instrumentation.new
      opts[:interceptors].prepend Grpcx::Server::Interceptors::ActiveRecord.new if defined?(::ActiveRecord)

      super(opts).tap do
        handle(health)
      end
    end

    def handle(service)
      health.add_status(service.service_name, ServingStatus::SERVING) if service.respond_to?(:service_name)
      super
    end

    def health
      @health ||= ::Grpc::Health::Checker.new
    end
  end
end
