# Thai ID Utils

Thai ID Utils is a zero-dependency Ruby gem for validating and decoding Thai national ID numbers.

Thai ID Utils เป็น Ruby gem ที่ไม่ต้องพึ่งพาไลบรารีเสริม สำหรับตรวจสอบความถูกต้องและถอดรหัสหมายเลขบัตรประชาชนไทย

[![Gem Version](https://badge.fury.io/rb/thai_id_utils.svg)](https://badge.fury.io/rb/thai_id_utils)

---

## Features / ฟีเจอร์

- Checksum validation (modulus-11 algorithm)
- Component decoding (category, province, district, sequence)
- Province name lookup for all 77 provinces
- Random valid ID generation
- Human-readable category descriptions (0–8)
- Laser ID validation and decoding
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

All 77 Thai provinces are supported via the `PROVINCE_CODES` constant.

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
# => "3601205234518"  (random, but checksum-valid)

# Override specific fields
ThaiIdUtils.generate(category: 1, office_code: "1001", sequence: "00001")
# => "1100100001XX"  (checksum digit computed automatically)
```

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
| `province_name(code)` | Returns province name for a 2-digit code, or `nil` |
| `category_description(n)` | Returns human-readable category description |
| `generate(...)` | Generates a random valid 13-digit ID |
| `laser_id_valid?(laser_id)` | Returns `true` if the laser ID format matches |
| `laser_id_decode(laser_id)` | Returns decoded laser ID hash; raises `InvalidIDError` on failure |
| `be_to_ce(year)` | Converts Buddhist Era year to Common Era |
| `ce_to_be(year)` | Converts Common Era year to Buddhist Era |

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
