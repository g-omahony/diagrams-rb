# frozen_string_literal: true

RSpec.describe Diagrams::Digraph do # rubocop:disable Metrics/BlockLength
  def capture_output(&block)
    dot_instance = Diagrams::Dot.new(test: true)

    allow(Diagrams::Dot).to receive(:new).and_return(dot_instance)

    described_class.new(test: true, &block)

    dot_instance.generate_image
  end

  shared_examples 'a diagram' do |dsl_code, expected_output|
    it 'generates the expected dot output' do
      result = capture_output { instance_eval(&dsl_code) }
      expected_output.each do |expected|
        expect(result).to include(expected)
      end
    end
  end

  context 'when adding a single node' do
    include_examples(
      'a diagram',
      proc {
        node 'A', label: 'Node A'
      },
      ['A [label="Node A"']
    )
  end

  context 'when adding two nodes with an edge' do
    include_examples(
      'a diagram',
      proc {
        node 'A', label: 'Node A'
        node 'B', label: 'Node B'
        edge 'A', to: 'B'
      },
      [
        'A [label="Node A"',
        'B [label="Node B"',
        'A -> B'
      ]
    )
  end

  context 'when adding a cluster with nodes' do
    include_examples(
      'a diagram',
      proc {
        cluster 'cluster 1' do
          node 'A', label: 'Node A'
          node 'B', label: 'Node B'
          edge 'A', to: 'B'
        end
      },
      [
        'subgraph cluster_cluster_1 {',
        'A [label="Node A"',
        'B [label="Node B"',
        'A -> B'
      ]
    )
  end

  context 'when nesting clusters' do
    include_examples(
      'a diagram',
      proc {
        cluster 'parent' do
          cluster 'child' do
            node 'A', label: 'Node A'
          end
          node 'B', label: 'Node B'
        end
      },
      [
        'subgraph cluster_parent {',
        'subgraph cluster_child {',
        'A [label="Node A"',
        'B [label="Node B"'
      ]
    )
  end

  context 'when nodes are inside and outside clusters' do
    include_examples(
      'a diagram',
      proc {
        cluster 'main' do
          node 'A', label: 'Node A'
        end
        node 'B', label: 'Node B'
        edge 'A', to: 'B'
      },
      [
        'subgraph cluster_main {',
        'A [label="Node A"',
        'B [label="Node B"',
        'A -> B'
      ]
    )
  end
end
