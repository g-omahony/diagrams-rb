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
            # Create or get the submodule dynamically
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

      def build_resources_md(path) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        resource_dir = "#{Dir.pwd}/#{path}"
        FileUtils.mkdir_p(resource_dir) unless Dir.exist?(resource_dir)

        @previous_title = ''.dup
        module_resources.each do |mod, methods|
          ns_name, title_idx = icon_namespace(mod)
          next if title_idx.nil?

          title = ns_name[0, title_idx]
          File.open("#{path}/#{title}.md", 'a') do |file|
            write_header(file, title)
            methods.each do |method_sym|
              file.write(
                "|\!\[\]\(#{icon_path(mod, method_sym)}\)#{icon_fmt}|`#{ns_name}.#{method_sym}`#{method_fmt}|\n"
              )
            end
          end
        end
      end

      def clean_resources_md(path)
        resource_dir = "#{Dir.pwd}/#{path}"
        files_to_delete(Dir.glob(File.join(resource_dir, '**', '*.md'))).each { |f| FileUtils.rm(f) }
      end

      def files_to_delete(files)
        files.select { |file| File.basename(file).match?(/^[A-Z]/) }
      end

      private

      def icon_namespace(mod)
        mod_sub = mod_substitute(mod)
        [mod_sub, title_index(mod_sub)]
      end

      def title_index(mod_sub)
        mod_sub.index(':') || mod_sub.index('.')
      end

      def mod_substitute(mod)
        mod.to_s.gsub('Diagrams::Resources::', '')
      end

      def write_header(file, title) # rubocop:disable Metrics/MethodLength
        return if title == @previous_title

        file.write("---\n")
        file.write("title: #{title}\n")
        file.write("parent: Sources\n")
        file.write("layout: page\n")
        file.write("nav_enabled: true\n")
        file.write("---\n")
        file.write("\n")
        file.write("| Icon | Source |\n")
        file.write("|:-----|:-----|\n")
        @previous_title = title
      end

      def icon_path(mod, method_sym)
        mod.__send__(method_sym)
      end

      def icon_fmt
        '{: width="22" }'
      end

      def method_fmt
        '{: .language-ruby .highlighter-rouge .highlight style="font-size: 14px"}'
      end

      def module_resources(namespace = self, collected_methods = {})
        namespace.constants.each do |const_name|
          const_value = namespace.const_get(const_name)

          next unless const_value.is_a?(Module)

          class_methods = const_value.singleton_methods
          collected_methods[const_value] = class_methods unless class_methods.empty?

          module_resources(const_value, collected_methods)
        end

        collected_methods
      end
    end
  end
end
