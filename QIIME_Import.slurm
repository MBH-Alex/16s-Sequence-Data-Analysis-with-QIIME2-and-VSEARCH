#!/bin/bash
#SBATCH --job-name=QIIME2_import
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --output=%j.output.import.txt
#SBATCH --partition=all
#SBATCH --time=01:00:00
#SBATCH --mail-type=begin,end
#SBATCH --mail-user=YOUR EMAIL HERE

module load QIIME2/2021.8

# Import Fastq folder into demultiplexed format
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path YOUR PATH TO DIRECTORY CONTAINING FILES HERE \
  --input-format CasavaOneEightSingleLanePerSampleDirFmt \
  --output-path demux-paired-end.qza

# Summarize demultiplexed data
qiime demux summarize \
  --i-data demux-paired-end.qza \
  --o-visualization demux-paired-end.qzv
