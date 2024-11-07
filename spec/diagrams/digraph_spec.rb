# frozen_string_literal: true

RSpec.describe Diagrams::Digraph do # rubocop:disable Metrics/BlockLength
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
    allow(Tempfile).to receive(:open).and_yield(mock_tempfile)
    allow(File).to receive(:write).with(mock_tempfile.path, dot_output)
    allow(Open3).to receive(:capture3).and_return(['', '', instance_double(Process::Status, success?: true)])
  end

  def get_dot_out(digraph)
    digraph.instance_variable_get(:@graph).dot_output
  end

  describe 'empty Digraph with defaults' do
    it 'writes dot output' do
      digraph =
        described_class.new do
        end
      expect(get_dot_out(digraph)).to eq(dot_output)
    end
  end

  describe 'Digraph with a node' do # rubocop:disable Metrics/BlockLength
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
            #{node}
        }
      TEXT
    end
    let(:node) do
      'node [label="node", image="/path/to/icon.png", shape=box,style=rounded,' \
        'fixedsize=true,width=1.4,height=1.4,labelloc=b,imagescale=true,penwidth=0,' \
        'fontname="Sans-Serif",fontsize=13,fontcolor="#2D3436"];'
    end

    it 'writes a node to the dot output' do
      digraph =
        described_class.new do
          node :node, label: 'node', icon: '/path/to/icon.png'
        end
      expect(get_dot_out(digraph)).to eq(dot_output)
    end
  end
end
