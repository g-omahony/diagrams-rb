# frozen_string_literal: true

RSpec.describe Diagrams::Digraph do
  let :digraph do
    described_class.new format: 'dot' do
    end
  end

  it 'creates defaults' do
    binding.pry
    expect(digraph).to be_nil
  end
end
