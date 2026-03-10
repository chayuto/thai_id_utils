# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-06-15

### Added
- Province code lookup (`PROVINCE_CODES`) mapping all 77 Thai provinces
- `province_name(code)` — return province name from 2-digit code
- Laser ID validation (`laser_id_valid?`) using format `XXN-NNNNNNN-NN`
- Laser ID decoding (`laser_id_decode`) into hardware version, box ID, and position
- Buddhist Era conversion: `be_to_ce(year)` and `ce_to_be(year)`
- `province_name` field included in `decode` output hash

## [0.1.2] - 2025-06-15

### Fixed
- Minor internal cleanup; no public API changes

## [0.1.1] - 2025-06-15

### Fixed
- Gemspec corrections and metadata updates

## [0.1.0] - 2025-06-15

### Added
- Initial release
- `valid?(id)` — checksum validation using Thailand's modulus-11 algorithm
- `decode(id)` — decode category, office code, province code, district code, sequence, and registration code
- `generate(...)` — generate a random valid 13-digit Thai national ID with optional overrides
- `category_description(category)` — human-readable description of ID category codes (0–8)
- `InvalidIDError` — raised on invalid IDs passed to `decode`

[0.2.0]: https://github.com/chayuto/thai_id_utils/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/chayuto/thai_id_utils/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/chayuto/thai_id_utils/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/chayuto/thai_id_utils/releases/tag/v0.1.0
