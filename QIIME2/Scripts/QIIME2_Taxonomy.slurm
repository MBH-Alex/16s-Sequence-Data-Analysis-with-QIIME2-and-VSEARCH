#!/bin/bash
#SBATCH --job-name=QIIME2_taxonomy
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --output=%j.output.taxonomy.txt
#SBATCH --partition=all
#SBATCH --time=02:00:00
#SBATCH --mem=60G
#SBATCH --mail-type=begin,end
#SBATCH --mail-user=your email here

module load QIIME2/2021.8

# Download classifier
wget https://data.qiime2.org/2024.2/common/silva-138-99-nb-classifier.qza

# Classify sequences
qiime feature-classifier classify-sklearn \
  --i-classifier silva-138-99-nb-classifier.qza \
  --i-reads rep-seqs.qza \
  --o-classification taxonomy.qza \
  --p-n-jobs 8  # Use 8 threads for parallel processing

# Summarize taxonomy
qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv

# Create taxa bar plots
qiime taxa barplot \
  --i-table table.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file REPLACE WITH YOUR METADATA FILE \
  --o-visualization taxa-bar-plots.qzv
