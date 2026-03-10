# frozen_string_literal: true

require 'minitest/autorun'
require 'thai_id_utils'

# Test suite for the ThaiIdUtils module
class TestThaiIdUtils < Minitest::Test
  VALID_ID         = '3012304567082'
  INVALID_ID       = '3012304567083'
  VALID_LASER_ID   = 'JC1-0002507-15'
  INVALID_LASER_ID = 'jc1-0002507-15'

  def test_valid_checksum
    assert ThaiIdUtils.valid?(VALID_ID)
    refute ThaiIdUtils.valid?(INVALID_ID)
  end

  def test_decode_valid_id
    info = ThaiIdUtils.decode(VALID_ID)
    assert_equal 3,                  info[:category]
    assert_equal '0123',             info[:office_code]
    assert_equal '01',               info[:province_code]
    assert_nil                       info[:province_name]
    assert_equal '23',               info[:district_code]
    assert_equal '04567',            info[:sequence]
    assert_equal '08',               info[:registration_code]
  end

  def test_decode_invalid_id
    assert_raises(ThaiIdUtils::InvalidIDError) { ThaiIdUtils.decode(INVALID_ID) }
  end

  def test_generate_default_id
    id = ThaiIdUtils.generate
    assert_equal 13, id.size
    assert_match(/\A\d{13}\z/, id)
    assert ThaiIdUtils.valid?(id)
  end

  def test_generate_with_options
    custom = ThaiIdUtils.generate(
      category: 2,
      office_code: 123,
      district_code: '45',
      sequence: 678
    )
    assert_equal 13, custom.size

    # category
    assert_equal '2', custom[0]
    # office_code padded to 4 digits with district override
    assert_equal '0145', custom[1..4]
    # district_code override
    assert_equal '45',   custom[3..4]
    # sequence padded to 5 digits
    assert_equal '00678', custom[5..9]

    assert ThaiIdUtils.valid?(custom)
  end

  def test_generate_only_office_code
    id = ThaiIdUtils.generate(office_code: 7)
    assert_equal '0007', id[1..4]
    assert_equal 13, id.size
    assert ThaiIdUtils.valid?(id)
  end

  def test_category_description_known
    # rubocop:disable Layout/LineLength
    expected = 'Thai nationals who were born after 1 January 1984 and had their birth notified within the given deadline (15 days).'
    # rubocop:enable Layout/LineLength
    assert_equal expected, ThaiIdUtils.category_description(1)
  end

  def test_category_description_unknown
    assert_equal 'Unknown category', ThaiIdUtils.category_description(99)
  end

  def test_province_name_known
    assert_equal 'Bangkok',           ThaiIdUtils.province_name('10')
    assert_equal 'Phuket',            ThaiIdUtils.province_name('83')
    assert_equal 'Nakhon Ratchasima', ThaiIdUtils.province_name('30')
  end

  def test_province_name_unknown
    assert_nil ThaiIdUtils.province_name('99')
    assert_nil ThaiIdUtils.province_name('01')
  end

  def test_be_to_ce
    assert_equal 1990, ThaiIdUtils.be_to_ce(2533)
    assert_equal 2024, ThaiIdUtils.be_to_ce(2567)
  end

  def test_ce_to_be
    assert_equal 2533, ThaiIdUtils.ce_to_be(1990)
    assert_equal 2567, ThaiIdUtils.ce_to_be(2024)
  end

  def test_laser_id_valid_true
    assert ThaiIdUtils.laser_id_valid?(VALID_LASER_ID)
  end

  def test_laser_id_valid_false
    refute ThaiIdUtils.laser_id_valid?(INVALID_LASER_ID)
    refute ThaiIdUtils.laser_id_valid?('JC1-002507-15')
    refute ThaiIdUtils.laser_id_valid?('J1C-0002507-15')
    refute ThaiIdUtils.laser_id_valid?('JC1-0002507-155')
  end

  def test_laser_id_decode_valid
    info = ThaiIdUtils.laser_id_decode(VALID_LASER_ID)
    assert_equal 'JC1',     info[:hardware_version]
    assert_equal '0002507', info[:box_id]
    assert_equal '15',      info[:position]
  end

  def test_laser_id_decode_invalid_raises
    assert_raises(ThaiIdUtils::InvalidIDError) { ThaiIdUtils.laser_id_decode(INVALID_LASER_ID) }
  end
end
