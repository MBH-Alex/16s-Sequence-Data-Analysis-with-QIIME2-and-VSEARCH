## Explanation
#!/bin/bash
#SBATCH --job-name=QIIME2_dada2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --output=%j.output.dada2.txt
#SBATCH --partition=all
#SBATCH --time=04:00:00
#SBATCH --mail-type=begin,end
#SBATCH --mail-user=alex.kidangathazhe@gmail.com

module load QIIME2/2021.8

# Denoise paired-end sequences using DADA2
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs demux-paired-end.qza \
  --p-trim-left-f 21 \
  --p-trim-left-r 10 \
  --p-trunc-len-f 295 \
  --p-trunc-len-r 238 \
  --o-table table.qza \
  --o-representative-sequences rep-seqs.qza \
  --o-denoising-stats denoising-stats.qza \
  --p-n-threads 0  # Use all available cores

# Summarize denoising stats
qiime metadata tabulate \
  --m-input-file denoising-stats.qza \
  --o-visualization stats-dada2.qzv

# Summarize feature table and tabulate sequences
qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.qzv \
  --m-sample-metadata-file Metadata.txt

qiime feature-table tabulate-seqs \
  --i-data rep-seqs.qza \
  --o-visualization rep-seqs.qzv
