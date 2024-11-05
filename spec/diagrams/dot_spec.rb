# frozen_string_literal: true

RSpec.describe Diagrams::Dot do # rubocop:disable Metrics/BlockLength
  let(:default_digraph) do
    <<~TEXT
      digraph G {
          pad=2.0;
          splines=ortho;
          nodesep=0.60;
          ranksep=0.75;
          rankdir=TB;
          fontname="Sans-Serif";
          fontsize=15;
          fontcolor="#2D3436";
    TEXT
  end

  it 'initalizes with defaults' do
    expect(described_class.new.dot_output).to eq(default_digraph)
  end

  describe 'add_node' do
    let(:default_node) do
      'default_node [label="", image="", shape=box,style=rounded,fixedsize=true,width=1.4,'\
        'height=1.4,labelloc=b,imagescale=true,penwidth=0,fontname="Sans-Serif",'\
        'fontsize=13,fontcolor="#2D3436"];'
    end
    let(:label) { 'Node Label' }
    let(:icon) { 'path/to/icon.png' }
    let(:fillcolor) { 'yellow;0.3:blue' }

    it 'creates node with defaults' do
      expect(described_class.new.add_node(:default_node).include?(default_node)).to be_truthy
    end

    it 'creates a node with the supplied label' do
      expect(described_class.new.add_node(:node, label: label).include?(label)).to be_truthy
    end

    it 'creates a node with a path to an icon image' do
      expect(described_class.new.add_node(:node, icon: icon).include?(icon)).to be_truthy
    end

    it 'creates a node with additional attributes' do
      expect(described_class.new.add_node(:node, fillcolor: fillcolor).include?(fillcolor)).to be_truthy
    end
  end
end
