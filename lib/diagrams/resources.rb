# frozen_string_literal: true

module Diagrams
  module Resources
    class << self
      def load_icons # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        root = File.expand_path('../..', __dir__)
        base_path = "#{root}/resources"

        Dir.glob("#{base_path}/**/*.png").each do |file_path|
          relative_path = file_path.sub("#{base_path}/", '')
          path_parts = relative_path.split('/')

          image_name_with_extension = path_parts.pop
          image_name_without_extension = File.basename(image_name_with_extension, '.png')

          current_module = self
          path_parts.each do |part|
            submodule = current_module.const_get(part.capitalize) rescue nil
            unless submodule
              submodule = Module.new
              current_module.const_set(part.capitalize, submodule)
            end
            current_module = submodule
          end

          current_module.define_singleton_method(image_name_without_extension.gsub('-', '_')) do
            file_path
          end
        end
      end
    end
  end
end
