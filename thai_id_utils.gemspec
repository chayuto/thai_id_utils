# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "thai_id_utils"
  spec.version       = ThaiIdUtils::VERSION
  spec.authors       = ["Chayut Orapinpatipat"]
  spec.email         = ["chayut_o@hotmail.com"]

  spec.summary       = "Utilities for validating and decoding Thai national IDs"
  spec.description   = "Provides checksum validation and component extraction (category, office, province, district, sequence) from Thai ID numbers."
  spec.homepage      = "https://github.com/chayuto/thai-id-utils"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.7"

  spec.files         = Dir["lib/**/*.rb"] + ["README.md", "Rakefile", "Gemfile"]
  spec.bindir        = "exe"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.0"
end