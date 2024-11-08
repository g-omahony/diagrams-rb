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
  let(:fillcolor) { 'yellow;0.3:blue' }

  it 'initalizes with defaults' do
    expect(described_class.new.send(:dot_output)).to eq(default_digraph)
  end

  describe '.add_node' do
    let(:default_node) do
      'default_node [label="", image="", shape=box,style=rounded,fixedsize=true,width=1.4,height=1.4,' \
      'labelloc=b,imagescale=true,penwidth=0,fontname="Sans-Serif",fontsize=13,fontcolor="#2D3436"];'
    end
    let(:label) { 'Node Label' }
    let(:icon) { 'path/to/icon.png' }

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

  describe '.add_cluster' do
    let(:default_cluster) do
      <<~TEXT
        subgraph cluster_cluster_1 {
            label="cluster 1";
            bgcolor="#E5F5FD";
            shape=box;
            style=rounded;
            labeljust=l;
            pencolor="#AEB6BE";
      TEXT
    end

    it 'creates a cluster with defaults' do
      expect(described_class.new.begin_cluster('cluster 1').include?(default_cluster)).to be_truthy
    end

    it 'creates a cluster with additional attributes' do
      expect(described_class.new.begin_cluster('cluster 1', fillcolor: fillcolor).include?(fillcolor)).to be_truthy
    end
  end

  describe '.add_edge' do
    let(:default_edge) do
      'a -> b [color="#7B8894",fontcolor="#2D3436",fontname="Sans-Serif",fontsize=13]'
    end

    it 'creates a edge with defaults' do
      expect(described_class.new.add_edge(:a, to: :b).include?(default_edge)).to be_truthy
    end

    it 'creates a edge with additional attributes' do
      expect(described_class.new.add_edge(:a, to: :b, fillcolor: fillcolor).include?(fillcolor)).to be_truthy
    end
  end

  describe '.generate_image' do # rubocop:disable Metrics/BlockLength
    let(:dot) { described_class.new }
    let(:dot_output) do
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
        }
      TEXT
    end
    let(:mock_tempfile) { instance_double(Tempfile, path: '/mock/tempfile/path') }

    before do
      allow(Diagrams::Dot).to receive(:new).and_return(dot)
      allow(Tempfile).to receive(:open).and_yield(mock_tempfile)
      allow(File).to receive(:write).with(mock_tempfile.path, dot_output)
      allow(Open3).to receive(:capture3).and_return(['', '', instance_double(Process::Status, success?: true)])
      allow(dot).to receive(:output_path).and_return('/path/to/output.png')
    end

    it 'writes dot output to a temporary file and calls the dot command to generate the image' do
      expect(Open3).to receive(:capture3).with("dot -Tpng #{mock_tempfile.path} -o /path/to/output.png")
      dot.generate_image
    end
  end
end
