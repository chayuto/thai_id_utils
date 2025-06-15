# Thai ID Utils

Thai ID Utils is a zero-dependency Ruby gem for validating and decoding Thai national ID numbers. It provides a simple API to check the official modulus-11 checksum, extract the embedded components (category, office code, district code, sequence), and get a human-readable description of the category code.
 
Thai ID Utils เป็น Ruby gem ที่ไม่ต้องพึ่งพาไลบรารีเสริม สำหรับตรวจสอบความถูกต้องและถอดรหัสหมายเลขบัตรประชาชนไทย โดยมี API ที่ใช้งานง่ายสำหรับตรวจสอบ checksum ตามมาตรฐาน modulus-11 ดึงส่วนประกอบต่างๆ (ประเภทผู้ลงทะเบียน รหัสหน่วยงาน รหัสอำเภอ และหมายเลขลำดับ) และแสดงคำอธิบายของรหัสประเภทในรูปแบบอ่านง่าย

## Usage / วิธีใช้งาน

```ruby
require "thai_id_utils"

id = "3012304567082"

# Validate checksum / ตรวจสอบความถูกต้องของ checksum
if ThaiIdUtils.valid?(id)
  puts "Valid!"
else
  puts "Invalid ID"
end

# Decode components / ถอดรหัสส่วนประกอบ
info = ThaiIdUtils.decode(id)
# => { category: 1, office_code: "6099", district_code: "99", sequence: "00257" }
puts info.inspect

# Get category description / คำอธิบายประเภท
desc = ThaiIdUtils.category_description(info[:category])
# => "Thai nationals who were born after 1 January 1984 and had their birth notified within the given deadline (15 days)."
puts desc

# Generate a new random valid ID / สร้างหมายเลขบัตรประชาชนใหม่แบบสุ่มที่ถูกต้อง
new_id = ThaiIdUtils.generate
puts new_id  # => e.g. "3601205234518"
```