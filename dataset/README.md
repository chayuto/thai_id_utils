---
annotations_creators:
  - programmatically-created
language_creators:
  - found
language:
  - th
license: mit
multilinguality:
  - monolingual
size_categories:
  - 100K<n<1M
source_datasets:
  - original
task_categories:
  - text-classification
  - token-classification
task_ids:
  - multi-class-classification
pretty_name: Synthetic Thai National ID Dataset
tags:
  - thai
  - national-id
  - synthetic
  - ocr
  - ekyc
  - fraud-detection
dataset_info:
  features:
    - name: id
      dtype: string
    - name: is_valid
      dtype: bool
    - name: category
      dtype: float64
    - name: category_description
      dtype: string
    - name: province_code
      dtype: string
    - name: province_name
      dtype: string
    - name: district_code
      dtype: string
    - name: office_code
      dtype: string
    - name: sequence
      dtype: string
    - name: registration_code
      dtype: string
    - name: laser_id
      dtype: string
  splits:
    - name: train
      num_examples: 315000
    - name: test
      num_examples: 35000
---

# Synthetic Thai National ID Dataset

> **This dataset is 100% synthetic. It contains no real citizen data, no personally identifiable information (PII), and no records derived from any real individual.**

A fully synthetic dataset of Thai 13-digit national identification numbers (เลขประจำตัวประชาชน) and their decoded components, generated for machine learning research and development.

Generated using the open-source [`thai_id_utils`](https://rubygems.org/gems/thai_id_utils) Ruby gem. The generation script and full reproducibility details are published at [github.com/chayuto/thai_id_utils](https://github.com/chayuto/thai_id_utils/tree/main/dataset).

**Dataset:** [huggingface.co/datasets/chayuto/thai-id-synthetic](https://huggingface.co/datasets/chayuto/thai-id-synthetic)

---

## Dataset Description

Thai national IDs are structured 13-digit numbers encoding a citizen's registration category, province, district, sequence, and a Modulo-11 checksum digit. This dataset provides:

- Structurally valid IDs with realistic geographic and demographic distributions
- A ~5% invalid-ID split (bad checksum, impossible province, wrong category, wrong length) for classifier training
- An independently generated laser ID column reflecting the real-world separation between the citizen ID and the card's supply-chain tracking code

---

## Intended Use

This dataset is intended for:

- Training and evaluating **ID format validators** (binary classification: valid/invalid)
- **OCR error simulation** — the wrong-length invalid strategy models digit insertion/deletion
- **eKYC and fraud-detection research** where structurally realistic synthetic IDs are needed without using real data
- **NLP/NER** tasks requiring Thai ID number tokens with known labels
- Educational purposes: learning the structure of Thai national ID numbers

### Out-of-scope Use

- This dataset must **not** be used to impersonate real individuals or to fabricate identity documents
- It is not a substitute for real demographic data — province/category distributions are approximations
- It does not encode names, dates of birth, gender, addresses, or any other personal attributes

---

## Data Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | 13-digit Thai national ID (synthetic) |
| `is_valid` | bool | Whether the ID passes checksum and structural validation |
| `category` | float (nullable) | Registration category digit (1–8); `null` for invalid rows |
| `category_description` | string (nullable) | Human-readable category description; `null` for invalid rows |
| `province_code` | string (nullable) | 2-digit province code (e.g. `"10"` = Bangkok); `null` for invalid rows |
| `province_name` | string (nullable) | Province name in English; `null` for invalid rows |
| `district_code` | string (nullable) | 2-digit district code within the province; `null` for invalid rows |
| `office_code` | string (nullable) | 4-digit registrar office code (province + district); `null` for invalid rows |
| `sequence` | string (nullable) | 5-digit personal sequence number; `null` for invalid rows |
| `registration_code` | string (nullable) | 2-digit chronological sequence marker; `null` for invalid rows |
| `laser_id` | string | Synthetic laser ID (`XXN-NNNNNNN-NN`), always present, generated **independently** of `id` |

All decoded fields (`category` through `registration_code`) are `null` for invalid rows (`is_valid: false`). The `laser_id` column is always populated and has no mathematical or statistical relationship to the `id` column, matching real-world card structure.

---

## Data Splits

| Split | Valid IDs | Invalid IDs | Total |
|-------|-----------|-------------|-------|
| train | 299,250 | 15,750 | 315,000 |
| test  | 33,250  | 1,750  | 35,000 |
| **Total** | **332,500** | **17,500** | **350,000** |

The valid/invalid ratio is 95%/5% in both splits. Rows are shuffled before splitting.

---

## Generation Details

### Province distribution

Province sampling is weighted by registered population (NSO 2023 estimates). Bangkok (`"10"`) receives ~15% of samples, reflecting its actual share of Thailand's ~71M population. All 77 provinces are represented with no remainder fallback.

### Category distribution

| Category | Description | Approx. % |
|----------|-------------|-----------|
| 1 | Born ≥1984, on-time registration | 62% |
| 3 | Born <1984, pre-digital registry | 20% |
| 2 | Born ≥1984, late registration | 8% |
| 8 | Naturalized / permanent foreign resident | 4% |
| 6 | Temporary foreign / yellow card | 3% |
| 5 | Census errors / special cases | 2% |
| 7 | Children of category-6, born in Thailand | 1% |

Category 4 is omitted (effectively unused in active registrations).

### Invalid ID strategies (distributed evenly across invalid rows)

1. **Bad checksum** — valid structure and province, but a digit is flipped to produce the wrong Modulo-11 check digit
2. **Impossible province** — structurally valid ID with a province code not in the official 77-province set (e.g. `"00"`, `"28"`, `"68"`)
3. **Bad category** — category digit `9` (undefined in the Thai ID specification)
4. **Wrong length** — 12 or 14 digits, simulating OCR digit truncation or insertion

### Laser ID

Laser IDs are generated independently from the citizen ID using known hardware-version prefixes (`JC`, `AA`, `BB`, `GC`) and realistic box/position ranges. This reflects the real-world structure where the laser code is a supply-chain identifier printed on the card's back surface, with no mathematical link to the citizen's ID number.

---

## Bias and Limitations

- Province weights are estimates based on NSO 2023 registered population, not exact DOPA registration counts
- District codes are constrained to each province's known district count but are not mapped to specific DOPA sub-district codes
- Sequence and registration code fields are uniformly random within their valid ranges — no demographic clustering
- The dataset does not include names, addresses, dates of birth, gender, or religion
- Category 4 is absent; the remaining category proportions are approximations of the living population distribution

---

## Ethical Considerations

All 350,000 records in this dataset are **algorithmically generated**. No Thai citizen's personal data was used, accessed, or referenced during generation. The IDs are valid in structure only — they do not correspond to any real person registered with the Department of Provincial Administration (DOPA).

The dataset is published to support legitimate ML research (fraud detection, OCR, eKYC) and must not be used to produce, verify, or impersonate real identity documents.

---

## Generation Reproducibility

```bash
git clone https://github.com/chayuto/thai_id_utils
cd thai_id_utils/dataset
gem install thai_id_utils -v 0.3.0
ruby generate.rb --count 350000 --invalid-ratio 0.05 --seed 42
```

| Published | Gem version | Seed |
|-----------|-------------|------|
| 2026-03-10 | thai_id_utils 0.3.0 | 42 |

---

## License

MIT — see [LICENSE](https://github.com/chayuto/thai_id_utils/blob/main/LICENSE).
