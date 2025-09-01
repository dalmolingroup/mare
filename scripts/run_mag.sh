INPUT_SAMPLESHEET="merged_samplesheet.csv"
OUTPUT_DIR="./nfcore_mag_results"
PROFILE="singularity"

nextflow run nf-core/mag \
    -profile ${PROFILE} \
    --input ${INPUT_SAMPLESHEET} \
    --outdir ${OUTPUT_DIR} \
    --skip_spades \
    --skip_spadeshybrid \
    --skip_gtdbtk \
    --kraken2_db db/k2_standard_16_GB_20250714.tar.gz \
    --skip_krona \
    --bin_domain_classification \
    --exclude_unbins_from_postbinning \
    --binqc_tool checkm2 \
    --refine_bins_dastool \
    --postbinning_input refined_bins_only \
    -resume \
    -with-tower
