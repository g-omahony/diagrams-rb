# frozen_string_literal: true

require 'open3'
require 'tempfile'

module Diagrams
  class Dot
    DEFAULTS = {
      GRAPH: {
        pad: '2.0',
        splines: 'ortho',
        nodesep: '0.60',
        ranksep: '0.75',
        rankdir: 'TB',
        fontname: '"Sans-Serif"',
        fontsize: '15',
        fontcolor: '"#2D3436"'
      },

      NODE: {
        shape: 'box',
        style: 'rounded',
        fixedsize: 'true',
        width: '1.4',
        height: '1.4',
        labelloc: 'b',
        imagescale: 'true',
        penwidth: '0',
        fontname: '"Sans-Serif"',
        fontsize: '13',
        fontcolor: '"#2D3436"'
      },

      CLUSTER: {
        shape: 'box',
        style: 'rounded',
        labeljust: 'l',
        pencolor: '"#AEB6BE"'
      },

      CLUSTER_BGCOLORS: %w[#E5F5FD #EBF3E7 #ECE8F6 #FDF7E3],

      EDGE: {
        color: '"#7B8894"',
        fontcolor: '"#2D3436"',
        fontname: '"Sans-Serif"',
        fontsize: '13'
      }
    }.freeze

    attr_accessor :format, :space, :clen, :test

    def initialize(**attrs)
      @format = attrs.delete(:format) || 'png'
      @test = attrs.delete(:test)
      DEFAULTS[:GRAPH].merge(attrs).each do |key, value|
        dot_output << "    #{key}=#{value};\n"
      end
      @space = '  '
      @clen = DEFAULTS[:CLUSTER_BGCOLORS].length
      @depth = 0
      @cluster_idx = -1
    end

    def dot_output
      @dot_output ||= "digraph G {\n".dup
    end

    def indent
      space * @depth
    end

    def add_node(id, label: '', icon: nil, **attrs)
      attributes = DEFAULTS[:NODE].merge(attrs).map { |k, v| "#{k}=#{v}" }.join(',')
      dot_output << "#{indent}    #{id} [label=\"#{label}\", image=\"#{icon}\", #{attributes}];\n"
    end

    def add_edge(from, to:, **attrs)
      attributes = DEFAULTS[:EDGE].merge(attrs).map { |k, v| "#{k}=#{v}" }.join(',')
      dot_output << "    #{from} -> #{to} [#{attributes}];\n"
    end

    def begin_cluster(label, **attrs) # rubocop:disable Metrics/AbcSize
      cluster_label = label.empty? ? "cluster_#{@cluster_idx += 1}" : label

      dot_output << "#{indent}subgraph cluster_#{identifier(cluster_label)} {\n"
      dot_output << "#{indent}    label=\"#{label}\";\n"
      dot_output << "#{indent}    bgcolor=\"#{DEFAULTS[:CLUSTER_BGCOLORS][@depth % clen]}\";\n"
      DEFAULTS[:CLUSTER].merge(attrs).each do |key, value|
        dot_output << "#{indent}   #{key}=#{value};\n"
      end
      @depth += 1
    end

    def end_cluster
      dot_output << "#{indent}}\n"
      @depth -= 1
    end

    def identifier(string)
      string.gsub(/\s+/, '_')
    end

    def generate_image
      dot_output << "}\n"
      return dot_output if test

      write_output
    end

    def write_output
      Tempfile.open('temp.dot') do |file|
        File.write(file.path, dot_output)

        cmd = "dot -T#{format} #{file.path} -o #{output_path}"
        _, stderr, status = Open3.capture3(cmd)
        puts stderr unless status.success?
      end
    end

    def output_path
      caller_locations.last.path.gsub('.rb', ".#{format}")
    end
  end
end
