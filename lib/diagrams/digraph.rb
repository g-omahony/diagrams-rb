# frozen_string_literal: true

require 'pry'

module Diagrams
  # DSL
  class Digraph
    def initialize(**attributes, &block)
      @graph = Dot.new(**attributes)
      instance_eval(&block)
      @graph.generate_image
    end

    def node(id, label: nil, icon: nil, **attributes)
      @graph.add_node(id, label: label, icon: icon, **attributes)
    end

    def edge(from, to:, **attributes)
      Array(from).each { |f| Array(to).each { |t| @graph.add_edge(f, to: t, **attributes) } }
    end

    def cluster(label, **attributes, &block)
      @graph.begin_cluster(label, **attributes)
      instance_eval(&block)
      @graph.end_cluster
    end
  end
end
