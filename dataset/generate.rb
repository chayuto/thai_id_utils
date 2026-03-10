#!/usr/bin/env ruby
# frozen_string_literal: true

# Synthetic Thai National ID dataset generator.
#
# Usage:
#   ruby generate.rb [options]
#
# Options:
#   --count N          Total rows to generate (default: 350000)
#   --invalid-ratio R  Fraction of invalid rows (default: 0.05)
#   --seed N           RNG seed for reproducibility (default: random, printed to stdout)
#   --output DIR       Output directory (default: output/)
#
# Outputs:
#   <output>/train.csv   90% of rows
#   <output>/test.csv    10% of rows

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'thai_id_utils'
require 'csv'
require 'optparse'

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

PROVINCE_WEIGHTS = {
  # Central
  '10' => 10.70, '11' => 1.25, '12' => 1.30, '13' => 1.20, '14' => 0.80,
  '15' => 0.29,  '16' => 0.76, '17' => 0.22, '18' => 0.34, '19' => 0.65,
  # Eastern
  '20' => 1.50,  '21' => 0.74, '22' => 0.52, '23' => 0.23,
  '24' => 0.71,  '25' => 0.44, '26' => 0.26, '27' => 0.55,
  # Northeastern
  '30' => 2.60,  '31' => 1.60, '32' => 1.40, '33' => 1.40, '34' => 1.90,
  '35' => 0.57,  '36' => 1.10, '37' => 0.37, '38' => 0.42, '39' => 0.52,
  '40' => 1.80,  '41' => 1.55, '42' => 0.63, '43' => 0.52, '44' => 0.95,
  '45' => 1.30,  '46' => 0.98, '47' => 1.10, '48' => 0.71, '49' => 0.36,
  # Northern
  '50' => 1.80,  '51' => 0.41, '52' => 0.75, '53' => 0.46, '54' => 0.46,
  '55' => 0.49,  '56' => 0.49, '57' => 1.30, '58' => 0.28,
  # Upper Central / Lower North
  '60' => 1.10,  '61' => 0.31, '62' => 0.72, '63' => 0.56, '64' => 0.60,
  '65' => 0.87,  '66' => 0.53, '67' => 1.00,
  # Western
  '70' => 0.88,  '71' => 0.85, '72' => 0.86, '73' => 0.90,
  '74' => 0.55,  '75' => 0.19, '76' => 0.48, '77' => 0.55,
  # Southern
  '80' => 1.55,  '81' => 0.47, '82' => 0.34, '83' => 0.39, '84' => 1.10,
  '85' => 0.19,  '86' => 0.51,
  '90' => 1.40,  '91' => 0.33, '92' => 0.66, '93' => 0.54,
  '94' => 0.72,  '95' => 0.52, '96' => 0.77
}.freeze

# Approximate category distribution based on Thai demographic structure.
# Category 4 omitted (effectively extinct in active use).
CATEGORY_WEIGHTS = {
  1 => 62, # Born >=1984, on-time registration — majority of active holders
  3 => 20, # Born <1984, pre-digital registry — living senior population
  2 => 8,  # Born >=1984, late registration — rural birth delay cases
  8 => 4,  # Naturalized / permanent foreign resident
  6 => 3,  # Temporary foreign / yellow card holders
  5 => 2,  # Census errors / special cases
  7 => 1   # Children of category-6 born in Thailand
}.freeze

INVALID_STRATEGIES = %i[bad_checksum impossible_province bad_category wrong_length].freeze

CSV_HEADERS = %w[
  id is_valid category category_description
  province_code province_name district_code office_code
  sequence registration_code laser_id
].freeze

# ---------------------------------------------------------------------------
# Weighted sampler
# ---------------------------------------------------------------------------

def build_sampler(weights)
  total = weights.values.sum.to_f
  cumulative = 0.0
  weights.map { |key, w| [key, (cumulative += w / total)] }
end

PROVINCE_SAMPLER = build_sampler(PROVINCE_WEIGHTS).freeze
CATEGORY_SAMPLER = build_sampler(CATEGORY_WEIGHTS).freeze

def weighted_sample(sampler)
  r = rand
  sampler.each { |key, threshold| return key if r <= threshold }
  sampler.last.first
end

# ---------------------------------------------------------------------------
# Row generators
# ---------------------------------------------------------------------------

def generate_valid_row
  province_code = weighted_sample(PROVINCE_SAMPLER)
  category      = weighted_sample(CATEGORY_SAMPLER)
  max_dist      = ThaiIdUtils::DISTRICT_COUNTS[province_code]
  district_code = format('%02d', rand(1..max_dist))

  id      = ThaiIdUtils.generate(category: category, province_code: province_code,
                                 district_code: district_code)
  decoded = ThaiIdUtils.decode(id)
  laser   = ThaiIdUtils.generate_laser_id

  {
    id: id,
    is_valid: true,
    category: decoded[:category],
    category_description: ThaiIdUtils.category_description(decoded[:category]),
    province_code: decoded[:province_code],
    province_name: decoded[:province_name],
    district_code: decoded[:district_code],
    office_code: decoded[:office_code],
    sequence: decoded[:sequence],
    registration_code: decoded[:registration_code],
    laser_id: laser
  }
end

# rubocop:disable Metrics/MethodLength
def generate_invalid_row
  strategy = INVALID_STRATEGIES.sample
  id = case strategy
       when :bad_checksum
         base   = ThaiIdUtils.generate
         digits = base.chars
         pos    = rand(0..11)
         digits[pos] = ((digits[pos].to_i + rand(1..9)) % 10).to_s
         digits.join

       when :impossible_province
         bad_pcode = %w[00 09 28 29 68 69].sample
         cat   = rand(1..6)
         dist  = format('%02d', rand(1..99))
         seq   = format('%05d', rand(0..99_999))
         reg   = format('%02d', rand(0..99))
         partial = "#{cat}#{bad_pcode}#{dist}#{seq}#{reg}"
         digits  = partial.chars.map(&:to_i)
         sum     = digits.each_with_index.sum { |d, i| d * (13 - i) }
         "#{partial}#{(11 - (sum % 11)) % 10}"

       when :bad_category
         base = ThaiIdUtils.generate
         "9#{base[1..]}"

       when :wrong_length
         base = ThaiIdUtils.generate
         rand(2).zero? ? base[0..11] : "#{base}#{rand(10)}"
       end

  {
    id: id,
    is_valid: false,
    category: nil, category_description: nil,
    province_code: nil, province_name: nil,
    district_code: nil, office_code: nil,
    sequence: nil, registration_code: nil,
    laser_id: ThaiIdUtils.generate_laser_id
  }
end
# rubocop:enable Metrics/MethodLength

# ---------------------------------------------------------------------------
# CLI options
# ---------------------------------------------------------------------------

options = { count: 350_000, invalid_ratio: 0.05, seed: nil, output: 'output' }

OptionParser.new do |opts|
  opts.banner = 'Usage: generate.rb [options]'
  opts.on('--count N',         Integer, 'Total rows (default: 350000)')       { |v| options[:count] = v }
  opts.on('--invalid-ratio R', Float,   'Invalid row fraction (default: 0.05)') { |v| options[:invalid_ratio] = v }
  opts.on('--seed N',          Integer, 'RNG seed for reproducibility')        { |v| options[:seed] = v }
  opts.on('--output DIR',      String,  'Output directory (default: output)')  { |v| options[:output] = v }
end.parse!

seed = options[:seed] || rand(1_000_000)
srand(seed)
puts "Seed: #{seed}  (pass --seed #{seed} to reproduce this exact output)"

total         = options[:count]
invalid_count = (total * options[:invalid_ratio]).round
valid_count   = total - invalid_count
train_count   = (total * 0.9).round
output_dir    = options[:output]

Dir.mkdir(output_dir) unless Dir.exist?(output_dir)

# ---------------------------------------------------------------------------
# Generate all rows, shuffle, split train/test, write CSVs
# ---------------------------------------------------------------------------

puts "Generating #{valid_count} valid + #{invalid_count} invalid rows..."

rows = Array.new(valid_count) { generate_valid_row } +
       Array.new(invalid_count) { generate_invalid_row }

rows.shuffle!

train_rows = rows[0...train_count]
test_rows  = rows[train_count..]

def write_csv(path, rows)
  CSV.open(path, 'w', headers: CSV_HEADERS, write_headers: true) do |csv|
    rows.each { |row| csv << CSV_HEADERS.map { |h| row[h.to_sym] } }
  end
end

train_path = File.join(output_dir, 'train.csv')
test_path  = File.join(output_dir, 'test.csv')

write_csv(train_path, train_rows)
write_csv(test_path,  test_rows)

puts "Written: #{train_path} (#{train_rows.size} rows)"
puts "Written: #{test_path}  (#{test_rows.size} rows)"
puts 'Done.'
