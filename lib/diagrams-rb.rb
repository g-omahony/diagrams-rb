# frozen_string_literal: true

require 'pry'
require 'pry-byebug'
require 'diagrams/version'

module Diagrams
  require 'diagrams/dot'
  require 'diagrams/digraph'
  require 'diagrams/resources'

  Resources.load_icons
  Resources.clean_resources_md('docs')
  Resources.build_resources_md('docs')
  include(Resources)
end
