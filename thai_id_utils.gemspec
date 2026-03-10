# frozen_string_literal: true

require_relative 'lib/thai_id_utils/version'
Gem::Specification.new do |spec|
  spec.name          = 'thai_id_utils'
  spec.version       = ThaiIdUtils::VERSION
  spec.authors       = ['Chayut Orapinpatipat']
  spec.email         = ['chayut_o@hotmail.com']

  spec.summary       = 'Validate, decode, and generate Thai national ID numbers'
  spec.description   = <<~DESC
    Zero-dependency Ruby utilities for Thai national ID numbers:
      • checksum validation (modulus-11),
      • component decoding (category, province, district, sequence),
      • province-constrained valid ID generation with DISTRICT_COUNTS,
      • province name lookup for all 77 provinces,
      • laser ID validation, decoding, and generation,
      • human-readable category descriptions (0–8),
      • Buddhist Era ↔ Common Era date conversion.
  DESC
  spec.homepage      = 'https://github.com/chayuto/thai_id_utils'
  spec.metadata    ||= {}
  spec.metadata['documentation_uri']     = 'https://rubydoc.info/gems/thai_id_utils'
  spec.metadata['source_code_uri']       = 'https://github.com/chayuto/thai_id_utils'
  spec.metadata['changelog_uri']         = 'https://github.com/chayuto/thai_id_utils/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 2.7'

  spec.files         = Dir['lib/**/*.rb'] + ['README.md', 'CHANGELOG.md', 'LICENSE']
  spec.bindir        = 'exe'
  spec.executables   = []
  spec.require_paths = ['lib']

  spec.add_development_dependency 'minitest', '~> 5.0'
end
