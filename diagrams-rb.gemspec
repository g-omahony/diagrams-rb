# frozen_string_literal: true

require_relative 'lib/diagrams/version'

Gem::Specification.new do |spec|
  spec.name = 'diagrams-rb'
  spec.version = Diagrams::VERSION
  spec.authors = ["Gerard O'Mahony"]
  spec.email = ['omahony.t.g@gmail.com']

  spec.summary = 'A Ruby DSL to construct cloud system architecture diagrams with Graphviz'
  spec.description = 'This Ruby-based DSL allows you to create complex Graphviz DOT diagrams programmatically.
    With this DSL, you can define nodes, edges,
    and nested clusters that represent relationships and hierarchies visually.'
  spec.homepage = 'https://github.com/g-omahony/diagrams-rb'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['documentation_uri'] = 'https://g-omahony.github.io/diagrams-rb-docs'
  spec.metadata['source_code_uri'] = 'https://github.com/g-omahony/diagrams-rb'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
