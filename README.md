# Thai ID Utils

Thai ID Utils is a zero-dependency Ruby gem for validating and decoding Thai national ID numbers.

Thai ID Utils เป็น Ruby gem ที่ไม่ต้องพึ่งพาไลบรารีเสริม สำหรับตรวจสอบความถูกต้องและถอดรหัสหมายเลขบัตรประชาชนไทย

[![Gem Version](https://badge.fury.io/rb/thai_id_utils.svg)](https://badge.fury.io/rb/thai_id_utils)

---

## Features / ฟีเจอร์

- Checksum validation (modulus-11 algorithm)
- Component decoding (category, province, district, sequence)
- Province name lookup for all 77 provinces
- Random valid ID generation — province-constrained by default, population-weighted sampling ready
- Human-readable category descriptions (0–8)
- Laser ID validation, decoding, and generation
- Buddhist Era ↔ Common Era date conversion

---

## Installation / การติดตั้ง

```ruby
gem 'thai_id_utils'
```

Or install directly:

```sh
gem install thai_id_utils
```

---

## Usage / วิธีใช้งาน

```ruby
require "thai_id_utils"
```

### Validate an ID / ตรวจสอบความถูกต้อง

```ruby
ThaiIdUtils.valid?("3012304567082")  # => true
ThaiIdUtils.valid?("1234567890123")  # => false
```

### Decode an ID / ถอดรหัสส่วนประกอบ

```ruby
info = ThaiIdUtils.decode("3012304567082")
# => {
#   category: 3,
#   office_code: "0123",
#   province_code: "01",
#   province_name: nil,       # nil if province code not recognized
#   district_code: "23",
#   sequence: "04567",
#   registration_code: "08"
# }
```

Raises `ThaiIdUtils::InvalidIDError` if the ID fails checksum validation.

### Province Name Lookup / ค้นหาชื่อจังหวัด

```ruby
ThaiIdUtils.province_name("10")  # => "Bangkok"
ThaiIdUtils.province_name("83")  # => "Phuket"
ThaiIdUtils.province_name("50")  # => "Chiang Mai"
ThaiIdUtils.province_name("99")  # => nil
```

All 77 Thai provinces are supported. Use `province_codes` to get the full list:

```ruby
ThaiIdUtils.province_codes
# => ["10", "11", "12", ..., "96"]  (77 codes)
```

### Category Description / คำอธิบายประเภทบัตร

```ruby
ThaiIdUtils.category_description(1)
# => "Thai nationals who were born after 1 January 1984 and had their birth notified within the given deadline (15 days)."

ThaiIdUtils.category_description(6)
# => "Foreign nationals who are living in Thailand temporarily and illegal migrants"
```

### Generate a Valid ID / สร้างหมายเลขบัตรประชาชนแบบสุ่ม

```ruby
ThaiIdUtils.generate
# => "1105312345671"  (random valid province, district within that province's range)

# Pin to a specific province (district randomised within province's known range)
ThaiIdUtils.generate(province_code: "10")   # Bangkok
ThaiIdUtils.generate(province_code: "83")   # Phuket (3 districts)

# Full override via office_code bypasses province validation (backwards compatible)
ThaiIdUtils.generate(category: 1, office_code: "1001", sequence: "00001")

# Raises ArgumentError for unknown province codes
ThaiIdUtils.generate(province_code: "99")   # => ArgumentError
```

The default generates a geographically valid ID — province code is sampled uniformly from the 77 known codes and the district code is constrained to that province's actual district count via `DISTRICT_COUNTS`.

### Laser ID Validation / ตรวจสอบเลขเลเซอร์

```ruby
ThaiIdUtils.laser_id_valid?("JC1-0002507-15")  # => true
ThaiIdUtils.laser_id_valid?("INVALID")          # => false
```

Format: `XXN-NNNNNNN-NN` (two uppercase letters, one digit, hyphen, 7 digits, hyphen, 2 digits)

### Laser ID Decoding / ถอดรหัสเลขเลเซอร์

```ruby
ThaiIdUtils.laser_id_decode("JC1-0002507-15")
# => {
#   hardware_version: "JC1",
#   box_id: "0002507",
#   position: "15"
# }
```

Raises `ThaiIdUtils::InvalidIDError` if the format is invalid.

### Generate a Laser ID / สร้างเลขเลเซอร์

```ruby
ThaiIdUtils.generate_laser_id
# => "JC2-0483921-07"  (random, always matches LASER_ID_FORMAT)

# Override individual components
ThaiIdUtils.generate_laser_id(hardware_version: "JC1", box_id: 2507, position: 15)
# => "JC1-0002507-15"
```

Known hardware version prefixes (`LASER_HARDWARE_VERSIONS`): `JC`, `AA`, `BB`, `GC`.
The laser ID is a supply-chain tracking code with no mathematical link to the citizen ID.

### Buddhist Era Conversion / แปลงปี พ.ศ. ↔ ค.ศ.

```ruby
ThaiIdUtils.be_to_ce(2567)  # => 2024
ThaiIdUtils.ce_to_be(2024)  # => 2567
```

---

## API Reference / สรุป API

| Method | Description |
|---|---|
| `valid?(id)` | Returns `true` if the 13-digit ID passes checksum |
| `decode(id)` | Returns a hash of decoded components; raises `InvalidIDError` on failure |
| `generate(category:, province_code:, office_code:, district_code:, sequence:)` | Generates a random valid 13-digit ID; defaults to a valid province |
| `province_name(code)` | Returns province name for a 2-digit code, or `nil` |
| `province_codes` | Returns all 77 valid 2-digit province code strings |
| `category_description(n)` | Returns human-readable category description |
| `laser_id_valid?(laser_id)` | Returns `true` if the laser ID format matches |
| `laser_id_decode(laser_id)` | Returns decoded laser ID hash; raises `InvalidIDError` on failure |
| `generate_laser_id(hardware_version:, box_id:, position:)` | Generates a random valid laser ID |
| `be_to_ce(year)` | Converts Buddhist Era year to Common Era |
| `ce_to_be(year)` | Converts Common Era year to Buddhist Era |

**Constants**

| Constant | Description |
|---|---|
| `PROVINCE_CODES` | Hash mapping 77 province codes to English names |
| `DISTRICT_COUNTS` | Hash mapping province codes to their district count |
| `LASER_HARDWARE_VERSIONS` | Array of known chip hardware-version prefixes |
| `LASER_ID_FORMAT` | Regex for laser ID format validation |

---

## Synthetic Dataset / ชุดข้อมูลสังเคราะห์

A 350,000-row fully synthetic dataset generated with this gem is published on HuggingFace:

**[huggingface.co/datasets/chayuto/thai-id-synthetic](https://huggingface.co/datasets/chayuto/thai-id-synthetic)**

- 332,500 valid IDs + 17,500 invalid IDs (bad checksum, impossible province, wrong category, wrong length)
- Population-weighted province sampling (NSO 2023), realistic category distribution
- train / test splits (315K / 35K)
- No real citizen data — 100% synthetic

To regenerate:

```sh
cd dataset
ruby generate.rb --count 350000 --invalid-ratio 0.05 --seed 42
```

---

## Development / การพัฒนา

```sh
# Run tests
rake

# Or directly
ruby -Ilib -Itest test/test_thai_id_utils.rb
```

---

## License / สัญญาอนุญาต

[MIT License](LICENSE)
