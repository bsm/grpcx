require 'rspec'
require 'grpcx'
require 'active_record'
require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "grpcx.spec.Message" do
    optional :name, :string, 1
  end
  add_enum "grpcx.spec.Enum" do
    value :V0, 0
    value :V1, 1
    value :V2, 2
  end
  add_message "grpcx.spec.GetMessageRequest" do
  end
end

module Grpcx::Spec
  Message = Google::Protobuf::DescriptorPool.generated_pool.lookup("grpcx.spec.Message").msgclass
  Enum = Google::Protobuf::DescriptorPool.generated_pool.lookup("grpcx.spec.Enum").enummodule
  GetMessageRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("grpcx.spec.GetMessageRequest").msgclass

  module Service
    class V1
      include GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'grpcx.spec.service.V1'

      rpc :GetMessage, GetMessageRequest, Message
    end

    Stub = V1.rpc_stub_class
  end

  class Server < GRPC::RpcServer
    include Grpcx::Server

    rescue_from 'ArgumentError' do |e|
      raise GRPC::InvalidArgument.new(errors: e.to_s)
    end
  end
end
