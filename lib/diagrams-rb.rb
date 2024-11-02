# frozen_string_literal: true

require 'diagrams/version'

module Diagrams
  require 'diagrams/dot'
  require 'diagrams/digraph'
  require 'diagrams/resources'

  Resources.load_icons
  include(Resources)
end
