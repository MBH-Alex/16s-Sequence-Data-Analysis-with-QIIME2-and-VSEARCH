# QIIME2-Slurm-Protocol-Scaria-Lab
This protocol outlines the steps for conducting a comprehensive microbiome analysis using Qiime2, on a SLURM computing cluster. The workflow includes data import, quality control, feature table construction, phylogenetic analysis, diversity metrics computation, taxonomic classification, and optional differential abundance analysis using ANCOM. This protocol is optimized for processing paired-end sequence data.
## General Prerequisites
This protocol is intended to be run on a SLURM based cluster, specifically the University of Oklahoma (OU) Schooner Cluster. As every cluster has its own quirks it should be understood that running this exact set of scripts in another SLURM based cluster may cause unexpected errors to occour. However, this protocol can generally be considered universal across all SLURM based clusters. 
The second prerequisite is a stable installation of QIIME2, prefferably as up to date as possible. If this is being run on the Schooner Cluster, this requirment has already been taken care of as the Schooner Cluster has several QIIME2 modules although they are quite out of date. 

Before starting the analysis, ensure the following prerequisites are met:
* **HPC Cluster Access**: Ensure you have access to a high-performance computing (HPC) cluster with SLURM job scheduler.
* **Qiime2 Installation**: Qiime2 should be installed and properly configured on the HPC cluster. The recommended way to install Qiime2 is via the Anaconda distribution. For installation instructions, refer to the Qiime2 Installation Guide. If running this on the Schooner cluster the module will suffice. 
* **Data Preparation**: Prepare your paired-end sequence data in the Casava 1.8 single-lane per sample format. Ensure that your data is organized in a directory structure suitable for Qiime2 import.
* **Metadata file**: Ensure you have a metadata file (e.g., Metadata.txt) that follows Qiime2's metadata format. This file will be used for mapping sample IDs to metadata categories.
## Running the Protocol
### Importing Data Into Qiime
The importing and demultiplexing script is the initial step in the Qiime2 workflow, where raw sequencing data is imported into the Qiime2 environment and, if necessary, demultiplexed. This step converts raw sequencing files into a format that Qiime2 can work with and prepares the data for subsequent analysis steps.

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
#### Key Points
* **Data Import**: The script imports raw sequencing data from FASTQ files into a Qiime2-compatible format.
* **Demultiplexing**: If your data is multiplexed, this step would handle the separation of sequences by sample based on barcodes (not explicitly shown here as the data is assumed to be already demultiplexed).
* **Quality Summary**: After importing, the script generates a summary of the demultiplexed data, providing insights into sequence quality, which can be reviewed using Qiime2 View (https://view.qiime2.org/).
#### Further Actions
Once this script has run it isi imperitive that the `demux-paired-end.qzv` file is taken off the cluster and then imported innto to Qiime2 View. This will allow for the determination of the base cutoffs during denoising.
#### Summary
This initial step sets the foundation for subsequent analyses by ensuring that the raw data is properly formatted and summarized, enabling informed decisions for downstream processing steps.
### Denoising the Samples
The denoising script is a crucial step in the Qiime2 workflow where raw sequence data is processed to remove noise, correct errors, and generate high-quality feature tables and representative sequences. This step utilizes the DADA2 algorithm, which is well-suited for high-resolution microbiome data analysis.

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
      --m-sample-metadata-file YOUR METADATA FILE HERE
    
    qiime feature-table tabulate-seqs \
      --i-data rep-seqs.qza \
      --o-visualization rep-seqs.qzv
#### Key Points
* **Denoising**: The script uses DADA2 to remove noise and correct errors in paired-end sequence data, resulting in high-quality feature tables and representative sequences.
* **Parallel Processing**: The script leverages all available cores to speed up the denoising process.
* **Summary and Visualization**: After denoising, the script generates summaries and visualizations of the denoising statistics, feature table, and representative sequences, which can be reviewed using Qiime2 View (https://view.qiime2.org/).
#### Further Actions
The `--p-trim-left-f`, `--p-trim-left-r`, `--p-trunc-len-f`, and `--p-trunc-len-r` must be changd before the script is run. By importing the `demux-paired-end.qzv` file in the Qiime2 View a quality report will be generated. The report will give a per base level of quality information that be used to set which bases will be trimmed based of the previous commands. The `--p-trim-left-f` corresponds to the left side of the forward reads while the `--p-trim-left-r` corresponds to the left side of the reverse reads. 
#### Summary
This step is essential for ensuring the accuracy and reliability of the downstream microbiome analyses by removing noise and correcting sequencing errors.
