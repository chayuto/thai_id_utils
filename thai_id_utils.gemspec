# frozen_string_literal: true

require_relative 'lib/thai_id_utils/version'
Gem::Specification.new do |spec|
  spec.name          = 'thai_id_utils'
  spec.version       = ThaiIdUtils::VERSION
  spec.authors       = ['Chayut Orapinpatipat']
  spec.email         = ['chayut_o@hotmail.com']

  spec.summary       = 'Validate and decode Thai national ID numbers'
  spec.description   = <<~DESC
    Zero-dependency Ruby utilities for:
      • checksum validation (modulus-11),
      • component decoding (category, office_code, district_code, sequence),
      • random valid ID generation,
      • human-readable category descriptions.
  DESC
  spec.homepage      = 'https://github.com/chayuto/thai_id_utils'
  spec.metadata    ||= {}
  spec.metadata['documentation_uri'] = 'https://github.com/chayuto/thai_id_utils#readme'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 2.7'

  spec.files         = Dir['lib/**/*.rb'] + ['README.md', 'Rakefile', 'Gemfile']
  spec.bindir        = 'exe'
  spec.executables   = []
  spec.require_paths = ['lib']

  spec.add_development_dependency 'minitest', '~> 5.0'
end
