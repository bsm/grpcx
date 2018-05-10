require 'spec_helper'

RSpec.describe Grpcx::Server do

  subject do
    s = Grpcx::Spec::Server.new
    s.handle Grpcx::Spec::Service::V1
    s
  end

  it 'should have a health-check' do
    expect(subject.health).to be_a(Grpc::Health::Checker)
    expect(subject.health.instance_variable_get(:@statuses)).to eq('grpcx.spec.service.V1' => 1)
  end

  it 'should have interceptors' do
    expect(subject.interceptors).to be_a(GRPC::InterceptorRegistry)

    registered = subject.interceptors.instance_variable_get(:@interceptors)
    expect(registered.size).to eq(3)
  end

end
