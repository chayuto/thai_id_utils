# thai_id_utils — Claude Project Guide

## Project Overview

Zero-dependency Ruby gem for Thai national ID utilities:
- Checksum validation (modulus-11)
- Component decoding (category, province, district, sequence)
- Random valid ID generation
- Human-readable category/province descriptions
- Laser ID validation and decoding
- Buddhist Era ↔ Common Era date conversion

Current version: `0.2.0` (see `lib/thai_id_utils/version.rb`)

## Structure

```
lib/
  thai_id_utils.rb          # All logic — single flat module (ThaiIdUtils)
  thai_id_utils/
    version.rb              # ThaiIdUtils::VERSION constant
    data/                   # Static data files (if any)
test/
  test_thai_id_utils.rb     # Minitest test suite
thai_id_utils.gemspec       # Gem spec
Rakefile                    # `rake` runs tests
```

## Conventions

- All files use `# frozen_string_literal: true`
- Module is flat: `ThaiIdUtils` (no nested classes except `InvalidIDError`)
- Public API methods are class methods (`self.method_name`)
- Method comments follow the `# Public:` style (GitHub/Tomdoc-ish)
- Rubocop is used — honor existing disable/enable comments

## Testing

```bash
ruby -Ilib -Itest test/test_thai_id_utils.rb
# or
rake
```

Framework: **Minitest** (`minitest ~> 5.0`)
Test class: `TestThaiIdUtils < Minitest::Test`
Constants: `VALID_ID = '3012304567082'`, `VALID_LASER_ID = 'JC1-0002507-15'`

Use `assert`/`refute`, `assert_equal`, `assert_raises`, `assert_nil` — avoid `expect`/`describe` syntax.

## Gem Publishing Workflow

1. Bump `VERSION` in `lib/thai_id_utils/version.rb`
2. Run tests: `rake`
3. Build: `gem build thai_id_utils.gemspec`
4. Push: `gem push thai_id_utils-X.Y.Z.gem`
5. Tag: `git tag vX.Y.Z && git push --tags`

## Key Business Logic

**Checksum (digits 1–12 weighted 13→2, check = (11 − sum%11) % 10)**
**Province code**: digits 2–3 of the ID (e.g., `'10'` = Bangkok, `'83'` = Phuket)
**Laser ID format**: `/\A[A-Z]{2}\d-\d{7}-\d{2}\z/` (e.g., `JC1-0002507-15`)
**Buddhist Era offset**: BE = CE + 543

## Allowed Bash Commands

- `ruby -Ilib -Itest test/test_thai_id_utils.rb 2>&1` — run tests
- `git add <files>` — stage files
