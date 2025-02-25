## Detailed Explanation of the DADA2 Script

    #!/bin/bash
    #SBATCH --job-name=QIIME2_dada2
    #SBATCH --nodes=1
    #SBATCH --ntasks-per-node=8
    #SBATCH --output=%j.output.dada2.txt
    #SBATCH --partition=all
    #SBATCH --time=04:00:00
    #SBATCH --mail-type=begin,end
    #SBATCH --mail-user=YOUR EMAIL HERE
    
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
### Explanation
1. SLURM Job Configuration
* `#!/bin/bash`: This line specifies that the script should be run in the Bash shell.
* `#SBATCH --job-name=QIIME2_dada2`: This sets the name of the job to "QIIME2_dada2".
* `#SBATCH --nodes=1`: This specifies that the job will use 1 node.
* `#SBATCH --ntasks-per-node=8`: This sets the number of tasks per node to 8.
* `#SBATCH --output=%j.output.dada2.txt`: This specifies the output file for the job logs, where %j is replaced with the job ID.
* `#SBATCH --partition=all`: This sets the partition (queue) to "all".
* `#SBATCH --time=04:00:00`: This sets the maximum run time to 4 hours.
* `#SBATCH --mail-type=begin,end`: This configures email notifications to be sent at the beginning and end of the job.
* `#SBATCH --mail-user=alex.kidangathazhe@gmail.com`: This specifies the email address to send notifications to.
2. Load Qiime2 Module
* `module load QIIME2/2021.8`: This line loads the Qiime2 module, making Qiime2 commands available for use.
3. Denoising with DADA2
* `qiime dada2 denoise-paired`: This command runs the DADA2 algorithm to denoise paired-end sequences.
  * `--i-demultiplexed-seqs demux-paired-end.qza`: This specifies the input file containing demultiplexed sequences.
  * `--p-trim-left-f 21`: This trims the first 21 bases from the forward reads. Please import the `demux-paired-end.qzv` file into QIIME2 to acertain what bases needed to be trimmed. 
  * `--p-trim-left-r 10`: This trims the first 10 bases from the reverse reads. Please import the `demux-paired-end.qzv` file into QIIME2 to acertain what bases needed to be trimmed.
  * `--p-trunc-len-f 295`: This truncates the forward reads to 295 bases. Please import the `demux-paired-end.qzv` file into QIIME2 to acertain what bases needed to be trimmed.
  * `--p-trunc-len-r 238`: This truncates the reverse reads to 238 bases. Please import the `demux-paired-end.qzv` file into QIIME2 to acertain what bases needed to be trimmed.
  * `--o-table table.qza`: This specifies the output file for the feature table.
  * `--o-representative-sequences rep-seqs.qza`: This specifies the output file for the representative sequences.
  * `--o-denoising-stats denoising-stats.qza`: This specifies the output file for the denoising statistics.
  * `--p-n-threads 0`: This uses all available cores for parallel processing.
4. Summarize Denoising Stats
* `qiime metadata tabulate`: This command generates a summary of the denoising statistics.
  * `--m-input-file denoising-stats.qza`: This specifies the input file containing denoising statistics.
  * `--o-visualization stats-dada2.qzv`: This specifies the output file for the denoising statistics visualization.
5. Summarize Feature Table and Tabulate Sequences
* `qiime feature-table summarize`: This command generates a summary of the feature table.
  * `--i-table table.qza`: This specifies the input feature table file.
  * `--o-visualization table.qzv`: This specifies the output file for the feature table visualization.
  * `--m-sample-metadata-file YOUR METADATA FILE HERE`: This specifies the metadata file for sample mapping. **THIS MUST POINT TO A METADATA FILE THAT HAS BEEN VALIDATED BY KEEMEI** To ensure the smoothing ruuning of the pipeline please validate your metadata file with Keemei (https://keemei.qiime2.org/).
* `qiime feature-table tabulate-seqs`: This command generates a summary of the representative sequences.
  * `--i-data rep-seqs.qza`: This specifies the input file containing representative sequences.
  * `--o-visualization rep-seqs.qzv`: This specifies the output file for the representative sequences visualization.
### General Comments
As stated in the README the trimming parameters need to be changed every run, it is perfectly acceptable to run this script multiple times to get different levels of trimming. The `stats-dada2.qzv` can be used to understand what impact the trimming settings have on the amount trimmed. 
#### `table.qzv` - Feature Table Summary
**Purpose**: The table.qzv file is a visualization of the feature table generated during the denoising process. It provides a summary of the number of sequences per sample and the number of features (OTUs/ASVs) detected.

**Contents**:
* Sample Detail: Information about each sample, including the total number of sequences.
* Feature Detail: Information about each feature (e.g., ASV), including its frequency across samples.
* Interactive Plots: Visualizations such as bar plots that show the distribution of sequences across samples.
**Usage**:
* Assess Sequencing Depth: Verify that sequencing depth is sufficient for each sample.
* Identify Outliers: Detect any samples with unusually high or low sequence counts.
* Explore Feature Distribution: Understand how features are distributed across different samples.
#### `rep-seqs.qzv` - Representative Sequences Summary
**Purpose**: The rep-seqs.qzv file is a visualization of the representative sequences. These sequences are the actual DNA sequences that were identified as unique features (ASVs) after denoising.

**Contents**:
* Sequence Detail: Information about each representative sequence, including its length and sequence.
* Interactive Tables: Tables listing each representative sequence along with its frequency in the dataset.
**Usage**:
* Sequence Verification: Review the actual sequences identified as features.
* Feature Analysis: Examine the length and composition of representative sequences.
* Downstream Analysis: Use the representative sequences for further analyses, such as taxonomy assignment or phylogenetic tree construction.
