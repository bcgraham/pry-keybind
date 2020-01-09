# frozen_string_literal: true

require File.dirname(__FILE__) + "/lib/version"

Gem::Specification.new do |gem|
  gem.name = "pry-keybind"
  gem.version = PryKeybind::VERSION
  gem.authors = ["Brian Graham"]
  gem.email = "bcgraham+github@gmail.com"
  gem.license = "MIT"
  gem.homepage = "https://github.com/bcgraham/pry-keybind"
  gem.summary = "Use readline keybindings in pry"
  gem.description = "Bind keys to execute commands in pry"

  gem.files = Dir["lib/**/*.rb", "LICENSE"]
  gem.extra_rdoc_files = %w[]
  gem.require_path = "lib"
  gem.executables = []

  # Dependencies
  gem.required_ruby_version = ">= 2.3.0"

  gem.add_runtime_dependency "pryline", ">= 0.0.1"
  gem.add_runtime_dependency "pry", "~> 0.10"
end
