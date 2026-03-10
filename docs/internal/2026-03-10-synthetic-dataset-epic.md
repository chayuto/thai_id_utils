# Synthetic Thai ID Dataset — Epic Planning
**Date:** 2026-03-10
**Status:** Implementation complete — gem v0.3.0, dataset scripts ready
**Target gem version:** 0.3.0
**Target dataset:** HuggingFace Hub

---

## 1. Goal

Generate a large, publicly-available synthetic Thai national ID dataset for use in:
- NLP / OCR model training (ID field extraction)
- e-KYC fraud detection classifiers
- Thai NER pipelines (detecting ID numbers in text)
- Data masking / anonymisation tooling

All records are **100% synthetic** — no real citizen data, no PII. The dataset is designed to be statistically realistic against Thailand's actual demographic and administrative structure.

---

## 2. What the Gem Already Provides

| Method | Usable? | Notes |
|--------|---------|-------|
| `ThaiIdUtils.generate(...)` | Partially | Province code is random 1–9999; generates impossible codes like `'28'`, `'68'` |
| `ThaiIdUtils.valid?(id)` | Yes | Used for post-generation verification |
| `ThaiIdUtils.decode(id)` | Yes | Extracts all components for dataset columns |
| `ThaiIdUtils.province_name(code)` | Yes | Used for `province_name` column |
| `ThaiIdUtils.category_description(cat)` | Yes | Used for `category_description` column |
| `ThaiIdUtils.laser_id_valid?` | Yes | Validation only; no generator yet |
| `ThaiIdUtils.laser_id_decode` | Yes | Used if we generate laser IDs |
| `ThaiIdUtils.be_to_ce` / `ce_to_be` | Yes | Date field generation |
| `PROVINCE_CODES` constant | Yes | Keys are the source of truth for valid province codes |

**Critical gap:** `generate` uses `rand(1..9_999)` for `office_code`, so ~70% of generated IDs have province codes that don't map to any real province. This must be fixed before the dataset work.

---

## 3. Gem v0.3.0 Changes Required

### 3.1 `province_codes` class method

```ruby
# Returns all valid 2-digit province code strings.
# @return [Array<String>]
def self.province_codes
  PROVINCE_CODES.keys
end
```

Simple accessor. Enables generators to sample from valid codes without coupling to the constant directly.

### 3.2 Fix `generate` — add `province_code:` parameter

Current signature:
```ruby
def self.generate(category:, office_code:, district_code:, sequence:)
```

New parameter added:
```ruby
def self.generate(
  category: rand(1..6),
  province_code: PROVINCE_CODES.keys.sample,  # NEW — defaults to a valid code
  office_code: nil,
  district_code: nil,
  sequence: nil
)
```

**Behaviour:**
- If `province_code:` is given, it overrides the first two digits of `office_code`
- If `office_code:` is also given explicitly, `office_code:` wins (backwards compatible)
- Default changes from random `1–9999` to `valid_province + rand(1..99)` for the district part

**Backwards compatibility:** Callers who pass `office_code:` explicitly are unaffected. Callers relying on the old random default now get valid province codes — this is a **behaviour fix**, not a break.

### 3.3 `DISTRICT_COUNTS` constant

Maps each province code to its number of administrative districts (amphoe / khet).
Used to generate realistic district codes within `generate`.

```ruby
DISTRICT_COUNTS = {
  '10' => 50,  # Bangkok (50 khet)
  '11' => 11,  # Samut Prakan
  '12' => 6,   # Nonthaburi
  '13' => 7,   # Pathum Thani
  '14' => 16,  # Phra Nakhon Si Ayutthaya
  '15' => 7,   # Ang Thong
  '16' => 11,  # Lopburi
  '17' => 6,   # Sing Buri
  '18' => 8,   # Chainat
  '19' => 13,  # Saraburi
  '20' => 11,  # Chonburi
  '21' => 8,   # Rayong
  '22' => 10,  # Chanthaburi
  '23' => 7,   # Trat
  '24' => 11,  # Chachoengsao
  '25' => 7,   # Prachin Buri
  '26' => 4,   # Nakhon Nayok
  '27' => 9,   # Sa Kaeo
  '30' => 32,  # Nakhon Ratchasima
  '31' => 23,  # Buri Ram
  '32' => 17,  # Surin
  '33' => 22,  # Si Sa Ket
  '34' => 25,  # Ubon Ratchathani
  '35' => 9,   # Yasothon
  '36' => 16,  # Chaiyaphum
  '37' => 7,   # Amnat Charoen
  '38' => 8,   # Bueng Kan
  '39' => 6,   # Nong Bua Lamphu
  '40' => 26,  # Khon Kaen
  '41' => 20,  # Udon Thani
  '42' => 14,  # Loei
  '43' => 18,  # Nong Khai
  '44' => 13,  # Maha Sarakham
  '45' => 20,  # Roi Et
  '46' => 18,  # Kalasin
  '47' => 18,  # Sakon Nakhon
  '48' => 12,  # Nakhon Phanom
  '49' => 7,   # Mukdahan
  '50' => 25,  # Chiang Mai
  '51' => 8,   # Lamphun
  '52' => 13,  # Lampang
  '53' => 9,   # Uttaradit
  '54' => 8,   # Phrae
  '55' => 15,  # Nan
  '56' => 9,   # Phayao
  '57' => 18,  # Chiang Rai
  '58' => 7,   # Mae Hong Son
  '60' => 15,  # Nakhon Sawan
  '61' => 8,   # Uthai Thani
  '62' => 11,  # Kamphaeng Phet
  '63' => 8,   # Tak
  '64' => 9,   # Sukhothai
  '65' => 9,   # Phitsanulok
  '66' => 12,  # Phichit
  '67' => 11,  # Phetchabun
  '70' => 10,  # Ratchaburi
  '71' => 13,  # Kanchanaburi
  '72' => 10,  # Suphanburi
  '73' => 7,   # Nakhon Pathom
  '74' => 7,   # Samut Sakhon
  '75' => 3,   # Samut Songkhram
  '76' => 8,   # Phetchaburi
  '77' => 8,   # Prachuap Khiri Khan
  '80' => 23,  # Nakhon Si Thammarat
  '81' => 8,   # Krabi
  '82' => 8,   # Phangnga
  '83' => 3,   # Phuket
  '84' => 19,  # Surat Thani
  '85' => 5,   # Ranong
  '86' => 8,   # Chumphon
  '90' => 16,  # Songkhla
  '91' => 7,   # Satun
  '92' => 10,  # Trang
  '93' => 11,  # Phatthalung
  '94' => 12,  # Pattani
  '95' => 8,   # Yala
  '96' => 9,   # Narathiwat
}.freeze
```

> **TODO before implementation:** Cross-check district counts against current DOPA data. Some amphoe were split or merged post-2010 (e.g. Bueng Kan province was carved from Nong Khai in 2011). The counts above are approximate and must be verified.

### 3.4 `generate_laser_id` class method

Format: `XX#-#######-##`
- Section 1: 2 uppercase letters + 1 digit (hardware version, e.g. `JC1`, `AA2`)
- Section 2: 7-digit zero-padded box number (1–9,999,999)
- Section 3: 2-digit zero-padded slot within box (1–60, observed max ~60 cards per box)

Known hardware version prefixes seen in the wild: `JC`, `AA`, `BB`, `GC`. We encode only observed ones to avoid generating unrealistic strings.

```ruby
LASER_HARDWARE_VERSIONS = %w[JC AA BB GC].freeze

def self.generate_laser_id(
  hardware_version: nil,
  box_id: nil,
  position: nil
)
  hw  = hardware_version || "#{LASER_HARDWARE_VERSIONS.sample}#{rand(1..3)}"
  box = format('%07d', box_id || rand(1..9_999_999))
  pos = format('%02d', position || rand(1..60))
  "#{hw}-#{box}-#{pos}"
end
```

### 3.5 Tests for all new methods

New test cases in `test/test_thai_id_utils.rb`:
- `test_province_codes_returns_all_valid_codes`
- `test_generate_with_province_code_uses_valid_province`
- `test_generate_default_uses_valid_province`
- `test_district_counts_all_province_codes_covered`
- `test_generate_laser_id_default_is_valid`
- `test_generate_laser_id_with_overrides`

---

## 4. Dataset Architecture

### 4.1 Repo structure

The dataset generator lives inside this repo but is **already excluded from the gem package** — the gemspec uses `Dir['lib/**/*.rb']` explicitly, so `dataset/` is never picked up. No gemspec change needed.

`dataset/output/` (generated CSV/Parquet) must be added to `.gitignore` — these files are large and fully reproducible; they must never be committed.

```
thai_id_utils/
├── lib/                          # gem source (unchanged)
├── test/                         # gem tests (unchanged)
├── dataset/
│   ├── README.md                 # HuggingFace dataset card (YAML front-matter + description)
│   ├── Gemfile                   # gem 'thai_id_utils', '~> 0.3'
│   ├── Gemfile.lock
│   ├── generate.rb               # main generation script
│   ├── upload.py                 # HuggingFace push script
│   ├── requirements.txt          # datasets, huggingface_hub, pyarrow, pandas
│   ├── .env.example              # HF_TOKEN=your_token_here
│   └── output/                   # gitignored — generated files go here
│       ├── train.csv
│       └── test.csv
└── docs/
    ├── Thai National ID...md     # existing reference doc
    └── internal/
        └── 2026-03-10-synthetic-dataset-epic.md   # this file
```

### 4.2 Dataset schema

Each row represents one synthetic Thai ID with its fully decoded metadata.

**`id` and `laser_id` are generated independently and carry no correlation.** In real-world usage the laser ID is a supply-chain code with no mathematical link to the 13-digit citizen ID; the synthetic dataset preserves this separation. Each column is sampled from its own generator.

| Column | Type | Source | Example |
|--------|------|--------|---------|
| `id` | string | `ThaiIdUtils.generate` | `"1101112345679"` |
| `is_valid` | bool | `ThaiIdUtils.valid?` | `true` |
| `category` | int | decoded from `id` | `1` |
| `category_description` | string | `ThaiIdUtils.category_description` | `"Thai nationals born after 1 Jan 1984..."` |
| `province_code` | string | decoded from `id` | `"10"` |
| `province_name` | string | `ThaiIdUtils.province_name` | `"Bangkok"` |
| `district_code` | string | decoded from `id` | `"05"` |
| `office_code` | string | decoded from `id` | `"1005"` |
| `sequence` | string | decoded from `id` | `"12345"` |
| `registration_code` | string | decoded from `id` | `"67"` |
| `laser_id` | string | `ThaiIdUtils.generate_laser_id` (independent) | `"JC1-0002507-15"` |

Split (`train`/`test`) is assigned at export time in `upload.py`, not stored in the CSV.

### 4.3 Invalid ID split

Include ~5% invalid IDs (bad checksum, impossible province code, out-of-range category) labelled `is_valid: false`. These are critical for training fraud-detection classifiers.

For invalid rows, `laser_id` is still generated independently as a valid laser ID string — because in real fraud scenarios the laser ID and the citizen ID are separate documents; a fraudster may have a valid physical card but submit a tampered ID number.

Invalid generation strategies (distributed evenly):
1. **Bad checksum** — take a valid ID, flip one digit in position 1–12
2. **Impossible province** — use a province code not in `PROVINCE_CODES` (e.g. `'00'`, `'28'`, `'09'`)
3. **Out-of-range category** — category `9` in the first digit
4. **Wrong length** — 12 or 14 digits (OCR truncation/insertion simulation)

---

## 5. Population-Weighted Province Sampling

Province sampling is weighted proportionally to registered population (NSO 2023 estimates, total ~71M). Weights are approximate population in millions; the generation script normalises them so they don't need to sum to any fixed value.

All 77 provinces are listed explicitly — no "remainder" fallback.

```ruby
PROVINCE_WEIGHTS = {
  # Central
  '10' => 10.70,  # Bangkok
  '11' => 1.25,   # Samut Prakan
  '12' => 1.30,   # Nonthaburi
  '13' => 1.20,   # Pathum Thani
  '14' => 0.80,   # Phra Nakhon Si Ayutthaya
  '15' => 0.29,   # Ang Thong
  '16' => 0.76,   # Lopburi
  '17' => 0.22,   # Sing Buri
  '18' => 0.34,   # Chainat
  '19' => 0.65,   # Saraburi
  # Eastern
  '20' => 1.50,   # Chonburi
  '21' => 0.74,   # Rayong
  '22' => 0.52,   # Chanthaburi
  '23' => 0.23,   # Trat
  '24' => 0.71,   # Chachoengsao
  '25' => 0.44,   # Prachin Buri
  '26' => 0.26,   # Nakhon Nayok
  '27' => 0.55,   # Sa Kaeo
  # Northeastern
  '30' => 2.60,   # Nakhon Ratchasima
  '31' => 1.60,   # Buri Ram
  '32' => 1.40,   # Surin
  '33' => 1.40,   # Si Sa Ket
  '34' => 1.90,   # Ubon Ratchathani
  '35' => 0.57,   # Yasothon
  '36' => 1.10,   # Chaiyaphum
  '37' => 0.37,   # Amnat Charoen
  '38' => 0.42,   # Bueng Kan
  '39' => 0.52,   # Nong Bua Lamphu
  '40' => 1.80,   # Khon Kaen
  '41' => 1.55,   # Udon Thani
  '42' => 0.63,   # Loei
  '43' => 0.52,   # Nong Khai
  '44' => 0.95,   # Maha Sarakham
  '45' => 1.30,   # Roi Et
  '46' => 0.98,   # Kalasin
  '47' => 1.10,   # Sakon Nakhon
  '48' => 0.71,   # Nakhon Phanom
  '49' => 0.36,   # Mukdahan
  # Northern
  '50' => 1.80,   # Chiang Mai
  '51' => 0.41,   # Lamphun
  '52' => 0.75,   # Lampang
  '53' => 0.46,   # Uttaradit
  '54' => 0.46,   # Phrae
  '55' => 0.49,   # Nan
  '56' => 0.49,   # Phayao
  '57' => 1.30,   # Chiang Rai
  '58' => 0.28,   # Mae Hong Son
  # Upper Central / Lower North
  '60' => 1.10,   # Nakhon Sawan
  '61' => 0.31,   # Uthai Thani
  '62' => 0.72,   # Kamphaeng Phet
  '63' => 0.56,   # Tak
  '64' => 0.60,   # Sukhothai
  '65' => 0.87,   # Phitsanulok
  '66' => 0.53,   # Phichit
  '67' => 1.00,   # Phetchabun
  # Western
  '70' => 0.88,   # Ratchaburi
  '71' => 0.85,   # Kanchanaburi
  '72' => 0.86,   # Suphanburi
  '73' => 0.90,   # Nakhon Pathom
  '74' => 0.55,   # Samut Sakhon
  '75' => 0.19,   # Samut Songkhram
  '76' => 0.48,   # Phetchaburi
  '77' => 0.55,   # Prachuap Khiri Khan
  # Southern
  '80' => 1.55,   # Nakhon Si Thammarat
  '81' => 0.47,   # Krabi
  '82' => 0.34,   # Phangnga
  '83' => 0.39,   # Phuket
  '84' => 1.10,   # Surat Thani
  '85' => 0.19,   # Ranong
  '86' => 0.51,   # Chumphon
  '90' => 1.40,   # Songkhla
  '91' => 0.33,   # Satun
  '92' => 0.66,   # Trang
  '93' => 0.54,   # Phatthalung
  '94' => 0.72,   # Pattani
  '95' => 0.52,   # Yala
  '96' => 0.77,   # Narathiwat
}.freeze
```

These weights live in `dataset/generate.rb`, not in the gem — they are dataset-generation policy, not gem logic.

**Why population weighting matters:** A uniform sampler produces Bangkok IDs 1/77 of the time (~1.3%), when Bangkok holds ~15% of Thailand's registered population. An ML model trained on uniform data would severely underrepresent the most common province patterns seen in real e-KYC pipelines.

---

## 6. Category Distribution

Based on demographic analysis (post-1984 population dominates):

| Category | Label | Approx. % | Rationale |
|----------|-------|-----------|-----------|
| 1 | Born ≥1984, on-time registration | 62% | Majority of active ID holders |
| 3 | Born before 1984, pre-digital registry | 20% | Living senior population |
| 2 | Born ≥1984, late registration | 8% | Rural birth delay cases |
| 8 | Naturalized / permanent foreign resident | 4% | Significant expat community |
| 6 | Temporary foreign / yellow card | 3% | Migrant workers |
| 5 | Census errors / special cases | 2% | Rare administrative category |
| 7 | Children of category 6, born in Thailand | 1% | Stateless youth |
| 4 | Pre-1984, missed census | 0% | Effectively extinct in active use |

Category 0 is excluded from generation (not issued on standard national ID cards).

---

## 7. HuggingFace Publishing Plan

### 7.1 Dataset card (`dataset/README.md`)

YAML front-matter:
```yaml
---
language:
  - th
license: mit
task_categories:
  - text-classification
  - token-classification
pretty_name: Synthetic Thai National ID Dataset
size_categories:
  - 100K<n<1M
tags:
  - thai
  - national-id
  - synthetic
  - ocr
  - ekyc
  - fraud-detection
---
```

Key sections:
- **Dataset Description** — what it is, what it's for, explicit statement that all IDs are synthetic
- **Data Fields** — schema table
- **Data Splits** — train (90%) / test (10%)
- **Generation Process** — references this gem by version
- **Bias and Limitations** — population weights are estimates; district codes are valid ranges, not exact DOPA sub-district codes
- **Licensing** — MIT

### 7.2 Upload script (`dataset/upload.py`)

```python
from datasets import Dataset, DatasetDict
import pandas as pd
from huggingface_hub import login

# Load CSVs generated by generate.rb
train_df = pd.read_csv("output/train.csv")
test_df  = pd.read_csv("output/test.csv")

ds = DatasetDict({
    "train": Dataset.from_pandas(train_df),
    "test":  Dataset.from_pandas(test_df),
})

ds.push_to_hub("your-org/thai-id-synthetic", private=False)
```

### 7.3 Target sizes

| Split | Valid IDs | Invalid IDs | Total |
|-------|-----------|-------------|-------|
| train | 285,000 | 15,000 | 300,000 |
| test  | 47,500 | 2,500 | 50,000 |
| **Total** | **332,500** | **17,500** | **350,000** |

350K rows generates in under 30 seconds with the Ruby script. Parquet output is ~12MB.

---

## 8. Generation Script Design (`dataset/generate.rb`)

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require 'thai_id_utils'
require 'csv'

# Build weighted province sampler
PROVINCE_WEIGHTS = { ... }.freeze  # from section 5
# Build weighted category sampler
CATEGORY_WEIGHTS = { ... }.freeze  # from section 6

def weighted_sample(weights_hash)
  total = weights_hash.values.sum.to_f
  r = rand * total
  cumulative = 0.0
  weights_hash.each do |key, weight|
    cumulative += weight
    return key if r < cumulative
  end
  weights_hash.keys.last
end

def generate_row(split:, valid: true)
  if valid
    province_code = weighted_sample(PROVINCE_WEIGHTS)
    category      = weighted_sample(CATEGORY_WEIGHTS)
    max_district  = ThaiIdUtils::DISTRICT_COUNTS[province_code]
    district_code = format('%02d', rand(1..max_district))

    id = ThaiIdUtils.generate(
      category: category,
      province_code: province_code,
      district_code: district_code
    )
    decoded = ThaiIdUtils.decode(id)
    laser   = ThaiIdUtils.generate_laser_id
    { id: id, is_valid: true, split: split, laser_id: laser, **decoded }
  else
    # Generate one of 4 invalid strategies at random
    generate_invalid_row(split: split)
  end
end

# ... write to CSV with configurable count via CLI args
```

CLI usage:
```bash
ruby dataset/generate.rb --count 350000 --invalid-ratio 0.05 --seed 42 --output dataset/output/
```

The `--seed` flag calls `srand(seed)` before generation begins, making the output fully reproducible. The seed value must be recorded in the dataset card alongside the gem version used, so any future regeneration produces identical output. If omitted, a random seed is used and printed to stdout for reference.

**Dataset overwrite policy:** When regenerating (e.g. after a gem patch), `upload.py` overwrites the existing HuggingFace dataset in-place. The dataset card records gem version + seed so consumers can audit what changed between pushes. No HF dataset versioning/branching needed.

---

## 9. Implementation Phases

### Phase 1 — Gem v0.3.0 (prerequisite)
- [ ] Add `DISTRICT_COUNTS` constant (verify counts from DOPA data)
- [ ] Add `LASER_HARDWARE_VERSIONS` constant
- [ ] Add `province_codes` class method
- [ ] Update `generate` — add `province_code:` param, use `DISTRICT_COUNTS` for district range
- [ ] Add `generate_laser_id` class method
- [ ] Write all new Minitest tests
- [ ] RuboCop clean
- [ ] Bump VERSION to `0.3.0`, update CHANGELOG
- [ ] `rake` passes, build and push gem

### Phase 2 — Dataset directory scaffold
- [ ] Create `dataset/` directory structure
- [ ] Add `dataset/output/` to `.gitignore`
- [ ] `dataset/Gemfile` with `gem 'thai_id_utils', '~> 0.3'`
- [ ] `dataset/requirements.txt` (datasets, huggingface_hub, pyarrow, pandas)
- [ ] `dataset/.env.example`
- [ ] Draft `dataset/README.md` (dataset card)

### Phase 3 — Generation script
- [ ] `dataset/generate.rb` — weighted sampler, valid + invalid rows, CSV output
- [ ] Smoke test: generate 1000 rows, verify schema and checksum on all valid rows
- [ ] Full run: generate 350K rows → `dataset/output/train.csv` + `test.csv`
- [ ] Inspect output distribution (province, category) — spot-check against expected weights

### Phase 4 — HuggingFace publish
- [ ] `dataset/upload.py` — convert CSV → Parquet, push to Hub
- [ ] Create HF dataset repo `your-org/thai-id-synthetic`
- [ ] Push dataset, verify dataset viewer loads correctly
- [ ] Finalise dataset card with row counts, generation date, gem version used
- [ ] Create GitHub release v0.3.0 with link to HF dataset

---

## 10. Decisions Made

| # | Decision |
|---|----------|
| 1 | `dataset/` is already excluded from gem package — gemspec uses `Dir['lib/**/*.rb']`, no change needed |
| 2 | All 77 provinces listed explicitly in `PROVINCE_WEIGHTS` — no "remainder equal share" fallback |
| 3 | `dataset/output/` added to `.gitignore` — generated files never committed |
| 4 | `id` and `laser_id` generated independently — no correlation, reflecting real-world structure |
| 5 | Invalid rows get a valid laser ID — fraud scenario is a tampered ID number, not a missing laser code |
| 6 | `generate.rb` accepts `--seed N` for reproducibility; seed + gem version recorded in dataset card |
| 7 | Dataset overwrite policy: regeneration overwrites HF dataset in-place, no versioning branches |
| 8 | `generate` raises `ArgumentError` on invalid `province_code:` input — fail fast |
| 9 | Dataset licence: MIT (consistent with gem) |

## 11. Remaining Open Questions

| # | Question | Owner |
|---|----------|-------|
| 1 | Verify district counts against current DOPA data (some amphoe split post-2010) | Pre-implementation |
| 2 | HuggingFace org/username to publish under? | Repo owner |
| 3 | Known laser ID hardware versions — `JC`, `AA`, `BB`, `GC` confirmed; any others? | Research |

---

## 12. What Is NOT in This Epic

- No real Thai citizen data of any kind
- No smart card APDU reading / NFC integration (separate domain)
- No name / address generation (separate Thai NLP dataset project)
- No date of birth, gender, or religion fields — out of scope for this gem
- No changes to the gem's public API beyond the additions listed above
