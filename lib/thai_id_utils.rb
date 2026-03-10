# frozen_string_literal: true

# ThaiIdUtils: Validate and decode Thai national ID numbers,
# providing checksum validation, component decoding, ID generation,
# and human-readable category descriptions.
module ThaiIdUtils
  class InvalidIDError < StandardError; end

  # ----------------------------------------------------------------------------
  # Mapping of category codes to their descriptions
  # ----------------------------------------------------------------------------
  # rubocop:disable Layout/LineLength
  CATEGORY_DESCRIPTIONS = {
    0 => '(Not found on cards of Thai nationals but may be found in the other issued identity cards below)',
    1 => 'Thai nationals who were born after 1 January 1984 and had their birth notified within the given deadline (15 days).',
    2 => 'Thai nationals who were born after 1 January 1984 but failed to have their birth notified in time.',
    3 => 'Thai nationals or foreign nationals with identification cards who were born and whose names were included in a house registration book before 1 January 1984',
    4 => 'Thai nationals who were born before 1 January 1984 but were not included in a house registration book at that time, for example due to moving residences',
    5 => 'Thai nationals who missed the official census or other special cases, for instance those of dual nationality',
    6 => 'Foreign nationals who are living in Thailand temporarily and illegal migrants',
    7 => 'Children of people of category 6 who were born in Thailand',
    8 => 'Foreign nationals who are living in Thailand permanently or Thai nationals by naturalization'
  }.freeze

  # Mapping of 2-digit province codes (digits 2-3 of the ID) to province names
  PROVINCE_CODES = {
    '10' => 'Bangkok',                    '11' => 'Samut Prakan',
    '12' => 'Nonthaburi',                 '13' => 'Pathum Thani',
    '14' => 'Phra Nakhon Si Ayutthaya',   '15' => 'Ang Thong',
    '16' => 'Lopburi',                    '17' => 'Sing Buri',
    '18' => 'Chainat',                    '19' => 'Saraburi',
    '20' => 'Chonburi',                   '21' => 'Rayong',
    '22' => 'Chanthaburi',                '23' => 'Trat',
    '24' => 'Chachoengsao',               '25' => 'Prachin Buri',
    '26' => 'Nakhon Nayok',               '27' => 'Sa Kaeo',
    '30' => 'Nakhon Ratchasima',          '31' => 'Buri Ram',
    '32' => 'Surin',                      '33' => 'Si Sa Ket',
    '34' => 'Ubon Ratchathani',           '35' => 'Yasothon',
    '36' => 'Chaiyaphum',                 '37' => 'Amnat Charoen',
    '38' => 'Bueng Kan',                  '39' => 'Nong Bua Lamphu',
    '40' => 'Khon Kaen',                  '41' => 'Udon Thani',
    '42' => 'Loei',                       '43' => 'Nong Khai',
    '44' => 'Maha Sarakham',              '45' => 'Roi Et',
    '46' => 'Kalasin',                    '47' => 'Sakon Nakhon',
    '48' => 'Nakhon Phanom',              '49' => 'Mukdahan',
    '50' => 'Chiang Mai',                 '51' => 'Lamphun',
    '52' => 'Lampang',                    '53' => 'Uttaradit',
    '54' => 'Phrae',                      '55' => 'Nan',
    '56' => 'Phayao',                     '57' => 'Chiang Rai',
    '58' => 'Mae Hong Son',
    '60' => 'Nakhon Sawan',               '61' => 'Uthai Thani',
    '62' => 'Kamphaeng Phet',             '63' => 'Tak',
    '64' => 'Sukhothai',                  '65' => 'Phitsanulok',
    '66' => 'Phichit',                    '67' => 'Phetchabun',
    '70' => 'Ratchaburi',                 '71' => 'Kanchanaburi',
    '72' => 'Suphanburi',                 '73' => 'Nakhon Pathom',
    '74' => 'Samut Sakhon',               '75' => 'Samut Songkhram',
    '76' => 'Phetchaburi',                '77' => 'Prachuap Khiri Khan',
    '80' => 'Nakhon Si Thammarat',        '81' => 'Krabi',
    '82' => 'Phangnga',                   '83' => 'Phuket',
    '84' => 'Surat Thani',                '85' => 'Ranong',
    '86' => 'Chumphon',
    '90' => 'Songkhla',                   '91' => 'Satun',
    '92' => 'Trang',                      '93' => 'Phatthalung',
    '94' => 'Pattani',                    '95' => 'Yala',
    '96' => 'Narathiwat'
  }.freeze
  # rubocop:enable Layout/LineLength

  LASER_ID_FORMAT = /\A[A-Z]{2}\d-\d{7}-\d{2}\z/.freeze

  # Validate a Thai national ID using Thailand’s modulus-11 checksum algorithm.
  #
  # @param id [String, Integer] 13-digit Thai national ID number
  # @return [Boolean] true if the checksum is valid, false otherwise
  def self.valid?(id)
    digits = id.to_s.chars.map(&:to_i)
    return false unless digits.size == 13

    sum = digits[0..11].each_with_index.sum { |d, i| d * (13 - i) }
    ((11 - (sum % 11)) % 10) == digits.last
  rescue StandardError
    false
  end

  # Decode the components encoded in a Thai national ID number.
  #
  # @param id [String, Integer] 13-digit Thai national ID number
  # @return [Hash] decoded fields:
  #   - `:category` [Integer] — registration category (0–8)
  #   - `:office_code` [String] — 4-digit registrar code (province + district)
  #   - `:province_code` [String] — first 2 digits of office_code
  #   - `:province_name` [String, nil] — province name, or nil if unknown
  #   - `:district_code` [String] — last 2 digits of office_code
  #   - `:sequence` [String] — 5-digit personal sequence number
  #   - `:registration_code` [String] — 2-digit chronological sequence marker
  # @raise [InvalidIDError] if the ID fails checksum validation
  def self.decode(id)
    raise InvalidIDError, 'Invalid ID' unless valid?(id)

    d = id.to_s.chars

    {
      category: d[0].to_i,
      office_code: d[1..4].join,
      province_code: d[1..2].join,
      province_name: PROVINCE_CODES[d[1..2].join],
      district_code: d[3..4].join,
      sequence: d[5..9].join,
      registration_code: d[10..11].join
    }
  end

  # Generate a random, valid 13-digit Thai national ID.
  # Any component can be overridden; the rest is randomized and the checksum is computed.
  #
  # @param category [Integer] ID category (1–8), default: random 1–6
  # @param office_code [Integer, String, nil] 4-digit registrar code, default: random
  # @param district_code [String, nil] 2-digit district override within office_code
  # @param sequence [Integer, String, nil] 5-digit personal sequence, default: random
  # @return [String] a valid 13-digit Thai national ID
  # rubocop:disable Metrics/AbcSize
  def self.generate(category: rand(1..6),
                    office_code: nil,
                    district_code: nil,
                    sequence: nil)
    # Build and override office_code/district_code
    office_code = format('%04d', office_code || rand(1..9_999))
    office_code[2..3] = district_code.to_s.rjust(2, '0') if district_code

    # Sequence (5 digits) and classification (2 digits)
    sequence       = format('%05d', sequence || rand(0..99_999))
    classification = format('%02d', rand(0..99))

    # First 12 digits: category + office_code + sequence + classification
    digits = [category.to_i] +
             office_code.chars.map(&:to_i) +
             sequence.chars.map(&:to_i) +
             classification.chars.map(&:to_i)

    # Checksum
    sum = digits.each_with_index.sum { |d, i| d * (13 - i) }
    check = (11 - (sum % 11)) % 10

    (digits + [check]).join
  end
  # rubocop:enable Metrics/AbcSize

  # Return the human-readable description for a Thai ID category code.
  #
  # @param category [Integer, String] category digit (0–8)
  # @return [String] description, or "Unknown category" if not found
  def self.category_description(category)
    CATEGORY_DESCRIPTIONS[category.to_i] || 'Unknown category'
  end

  # Return the province name for a 2-digit province code.
  #
  # @param code [String] 2-digit province code (e.g., "10" for Bangkok)
  # @return [String, nil] province name, or nil if the code is not recognized
  def self.province_name(code)
    PROVINCE_CODES[code.to_s]
  end

  # Convert a Buddhist Era year to Common Era (subtract 543).
  #
  # @param year [Integer, String] Buddhist Era year (e.g., 2567)
  # @return [Integer] Common Era year (e.g., 2024)
  def self.be_to_ce(year)
    year.to_i - 543
  end

  # Convert a Common Era year to Buddhist Era (add 543).
  #
  # @param year [Integer, String] Common Era year (e.g., 2024)
  # @return [Integer] Buddhist Era year (e.g., 2567)
  def self.ce_to_be(year)
    year.to_i + 543
  end

  # Validate the format of a Thai ID card laser ID (printed on the card back).
  # Expected format: XXN-NNNNNNN-NN  (e.g., JC1-0002507-15)
  #
  # @param laser_id [String] the laser ID string to validate
  # @return [Boolean] true if format matches, false otherwise
  def self.laser_id_valid?(laser_id)
    LASER_ID_FORMAT.match?(laser_id.to_s)
  end

  # Decode a Thai ID card laser ID into its components.
  #
  # @param laser_id [String] laser ID string (e.g., "JC1-0002507-15")
  # @return [Hash] decoded fields:
  #   - `:hardware_version` [String] — chip generation code (e.g., "JC1")
  #   - `:box_id` [String] — distribution box number (e.g., "0002507")
  #   - `:position` [String] — slot within the box (e.g., "15")
  # @raise [InvalidIDError] if the laser ID format is invalid
  def self.laser_id_decode(laser_id)
    raise InvalidIDError, 'Invalid laser ID' unless laser_id_valid?(laser_id)

    parts = laser_id.to_s.split('-')
    {
      hardware_version: parts[0],
      box_id: parts[1],
      position: parts[2]
    }
  end
end
