#!/usr/bin/env python3
"""
Upload the synthetic Thai ID dataset to HuggingFace Hub.

Prerequisites:
    pip install -r requirements.txt
    cp .env.example .env && edit .env with your HF_TOKEN and HF_REPO

Usage:
    python upload.py
"""

import os
import sys
from pathlib import Path

import pandas as pd
from datasets import Dataset, DatasetDict
from dotenv import load_dotenv
from huggingface_hub import login

load_dotenv()

HF_TOKEN = os.getenv("HF_TOKEN")
HF_REPO  = os.getenv("HF_REPO")

if not HF_TOKEN or not HF_REPO:
    print("Error: HF_TOKEN and HF_REPO must be set in .env", file=sys.stderr)
    sys.exit(1)

OUTPUT_DIR = Path(__file__).parent / "output"
TRAIN_CSV  = OUTPUT_DIR / "train.csv"
TEST_CSV   = OUTPUT_DIR / "test.csv"

for path in (TRAIN_CSV, TEST_CSV):
    if not path.exists():
        print(f"Error: {path} not found. Run generate.rb first.", file=sys.stderr)
        sys.exit(1)

print(f"Loading CSVs from {OUTPUT_DIR}...")
train_df = pd.read_csv(TRAIN_CSV)
test_df  = pd.read_csv(TEST_CSV)

# Nullable string columns — cast to str only where not null to avoid "nan" strings
NULLABLE_STR_COLS = [
    "category_description",
    "province_code", "province_name",
    "district_code", "office_code",
    "sequence", "registration_code",
]

def coerce_dtypes(df):
    df["id"]       = df["id"].astype(str).str.zfill(13)
    df["is_valid"] = df["is_valid"].astype(bool)
    df["category"] = pd.to_numeric(df["category"], errors="coerce")
    for col in NULLABLE_STR_COLS:
        df[col] = df[col].where(df[col].isna(), df[col].astype(str))

for df in (train_df, test_df):
    coerce_dtypes(df)

ds = DatasetDict({
    "train": Dataset.from_pandas(train_df, preserve_index=False),
    "test":  Dataset.from_pandas(test_df,  preserve_index=False),
})

print(f"Train: {len(train_df):,} rows  |  Test: {len(test_df):,} rows")
print(f"Uploading to {HF_REPO}...")

login(token=HF_TOKEN)
ds.push_to_hub(HF_REPO, private=False)

print(f"Done. Dataset live at https://huggingface.co/datasets/{HF_REPO}")
