# frozen_string_literal: true

RSpec.describe Diagrams::Digraph do
  let :digraph do
    described_class.new format: 'dot' do
    end
  end

  it 'creates defaults' do
    expect(digraph).to an_instance_of(described_class)
  end
end
