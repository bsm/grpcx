require 'spec_helper'

RSpec.describe Grpcx::Entity do
  it 'builds messages' do
    msg = described_class.build Grpcx::Spec::Message,
                                name: 'Name',
                                version: 1,
                                types: {
                                  num: 8,
                                  truth: [1, 0, true, 'true'],
                                  decimal: '1.2',
                                }

    expect(msg.to_h).to eq(
      name: 'Name',
      version: :V1,
      types: {
        num: 8,
        truth: [true, false, true, true],
        decimal: 1.2,
      },
    )
  end
end
