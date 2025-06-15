# frozen_string_literal: true

require "thai_id_utils/version"

module ThaiIdUtils
  class InvalidIDError < StandardError; end

  # Mapping of category codes to their descriptions
  CATEGORY_DESCRIPTIONS = {
    0 => "(Not found on cards of Thai nationals but may be found in the other issued identity cards below)",
    1 => "Thai nationals who were born after 1 January 1984 and had their birth notified within the given deadline (15 days).",
    2 => "Thai nationals who were born after 1 January 1984 but failed to have their birth notified in time.",
    3 => "Thai nationals or foreign nationals with identification cards who were born and whose names were included in a house registration book before 1 January 1984",
    4 => "Thai nationals who were born before 1 January 1984 but were not included in a house registration book at that time, for example due to moving residences",
    5 => "Thai nationals who missed the official census or other special cases, for instance those of dual nationality",
    6 => "Foreign nationals who are living in Thailand temporarily and illegal migrants",
    7 => "Children of people of category 6 who were born in Thailand",
    8 => "Foreign nationals who are living in Thailand permanently or Thai nationals by naturalization"
  }.freeze

  # Public: Validate checksum using Thailand’s modulus-11 algorithm
  def self.valid?(id)
    digits = id.to_s.chars.map(&:to_i)
    return false unless digits.size == 13

    sum = digits[0..11].each_with_index.sum { |d, i| d * (13 - i) }
    ((11 - (sum % 11)) % 10) == digits.last
  rescue
    false
  end

  # Public: Decode components present in a Thai ID
  # Returns a hash with :category (Integer), :office_code (String),
  # :district_code (String), and :sequence (String)
  def self.decode(id)
    raise InvalidIDError, "Invalid ID" unless valid?(id)
    d = id.to_s.chars

    {
      category:      d[0].to_i,
      office_code:   d[1..4].join,
      district_code: d[3..4].join,
      sequence:      d[5..9].join
    }
  end

  # Public: Generate a random, valid 13-digit Thai national ID
  # Optional keyword args to specify parts; random values used when omitted.
  def self.generate(category: rand(1..6), office_code: nil, district_code: nil, sequence: nil)
    # Build office code and apply any district override
    office_code = format("%04d", office_code || rand(1..9999))
    if district_code
      district_code = district_code.to_s.rjust(2, '0')
      office_code[2..3] = district_code
    end

    # Sequence (5 digits) and classification (2 digits)
    sequence       = format("%05d", sequence || rand(0..99999))
    classification = format("%02d", rand(0..99))

    # Build the first 12 digits: category + office_code (4) + sequence (5) + classification (2)
    digits = []
    digits << category.to_i
    digits += office_code.chars.map(&:to_i)
    digits += sequence.chars.map(&:to_i)
    digits += classification.chars.map(&:to_i)

    # Compute checksum and assemble full ID
    sum         = digits.each_with_index.sum { |d, i| d * (13 - i) }
    check_digit = (11 - (sum % 11)) % 10
    (digits + [check_digit]).join
  end

  # Public: Return a human-readable description for a category code
  def self.category_description(category)
    CATEGORY_DESCRIPTIONS[category.to_i] || "Unknown category"
  end
end
