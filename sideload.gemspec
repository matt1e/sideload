# frozen_string_literal: true
$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sideload/version"

Gem::Specification.new do |s|
  s.name        = "sideload"
  s.version     = Sideload::VERSION

  s.summary     = "Validated data copying"
  s.description = "Offers a safe way to copy (config) files through different" \
    "storages"
  s.authors     = ["Matthias Geier"]
  s.email       = "mayutamano@gmail.com "
  s.homepage    = "https://github.com/matthias-geier/sideload"
  s.license     = "BSD-2-Clause"

  s.files       = Dir["lib/**/*.rb", "LICENSE"]
  s.executables = []
  s.test_files  = Dir["test/**/*"]

  s.add_development_dependency "minitest", "~> 5.10"
end
