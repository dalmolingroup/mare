#!/bin/bash

# ==============================================================================
# Bash script to merge FASTQ files from different lanes for the same sample
# ==============================================================================
#
# This script reads an nf-core-style samplesheet, merges the short reads
# (R1 and R2) for each unique sample, and creates a new samplesheet
# pointing to the merged files.
#
# It will safely skip any files listed in the samplesheet that are not found
# on disk and print a warning.
#
# How to run:
# 1. Save this script as `merge_lanes.sh`.
# 2. Make sure `samplesheet.csv` is in the same directory.
# 3. Make the script executable: chmod +x merge_lanes.sh
# 4. Execute it: ./merge_lanes.sh
#
# ==============================================================================

# --- Configuration ---

# The input samplesheet from the previous step.
INPUT_CSV="samplesheet.csv"

# The directory where merged FASTQ files will be stored.
MERGED_DIR="merged_fastqs"

# The name of the new samplesheet that will be generated.
OUTPUT_CSV="merged_samplesheet.csv"

# --- Script Logic ---

# Check if the input samplesheet exists
if [ ! -f "$INPUT_CSV" ]; then
    echo "Error: Input file '$INPUT_CSV' not found."
    exit 1
fi

# Create the output directory if it doesn't exist
mkdir -p "$MERGED_DIR"
echo "📂 Created output directory: $MERGED_DIR"

# Write the header for the new samplesheet
echo "sample,group,short_reads_1,short_reads_2,long_reads" > "$OUTPUT_CSV"

echo "🚀 Starting lane merging process..."

# Get unique sample IDs from the first column of the CSV, skipping the header
SAMPLES=$(tail -n +2 "$INPUT_CSV" | cut -d',' -f1 | sort -u)

# Loop over each unique sample ID
for sample_id in $SAMPLES; do
    echo "---------------------------------"
    echo "Processing sample: $sample_id"

    # --- Get file paths for the current sample ---
    R1_FILES=$(grep "^${sample_id}," "$INPUT_CSV" | cut -d',' -f3)
    R2_FILES=$(grep "^${sample_id}," "$INPUT_CSV" | cut -d',' -f4)
    GROUP=$(grep "^${sample_id}," "$INPUT_CSV" | head -n 1 | cut -d',' -f2)

    # --- Define output file names ---
    MERGED_R1="${MERGED_DIR}/${sample_id}_merged_R1.fastq.gz"
    MERGED_R2="${MERGED_DIR}/${sample_id}_merged_R2.fastq.gz"

    # Create/truncate the output files before appending
    > "$MERGED_R1"
    > "$MERGED_R2"

    echo "   Merging R1 files into: $MERGED_R1"
    # Loop through each R1 file, check for existence, then concatenate
    for file in $R1_FILES; do
        if [ -f "$file" ]; then
            cat "$file" >> "$MERGED_R1"
        else
            # Print a warning to standard error if a file is not found
            echo "   [Warning] File not found, skipping: $file" >&2
        fi
    done

    echo "   Merging R2 files into: $MERGED_R2"
    # Loop through each R2 file, check for existence, then concatenate
    for file in $R2_FILES; do
        if [ -f "$file" ]; then
            cat "$file" >> "$MERGED_R2"
        else
            # Print a warning to standard error if a file is not found
            echo "   [Warning] File not found, skipping: $file" >&2
        fi
    done

    # --- Append the new entry to the output CSV ---
    echo "${sample_id},${GROUP},${MERGED_R1},${MERGED_R2}," >> "$OUTPUT_CSV"

done

echo "---------------------------------"
echo "✅ Done! Merged samplesheet created at: $OUTPUT_CSV"

