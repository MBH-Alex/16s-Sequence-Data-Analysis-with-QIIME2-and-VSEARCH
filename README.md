# Comparing QIIME2 and VSEARCH
Qiime2 and VSEARCH are both widely used tools in microbiome analysis of 16s sequence data. Qiime2 has quickly emerged as the foremost option for comprehensive analysis of sequence data against a reference databases like SILVA or Greengenes. VSEARCH on the other hand is a bit more niche but has (in my experience) demonstrated greater classification ability when working with a defined community. 

1. **Overview**

| Feature | QIIME2 | VSEARCH |
| ------- | ------ | ------- |
| Primary Purpose |	A comprehensive microbiome analysis pipeline for data processing, analysis, and visualization |	A fast tool for sequence clustering, chimera detection, and searching against reference databases |
| Functionality |	End-to-end workflow: importing, filtering, denoising, taxonomy assignment, diversity analysis |	Sequence quality filtering, merging, dereplication, clustering, and chimera checking |
| Ease of Use |	Higher learning curve but well-documented | Command-line based, relatively simple for specific tasks |
| Output | Feature tables, taxonomy assignments, diversity metrics, visualizations | OTU tables, cluster reports, chimera reports |
| Computational Efficiency | More computationally intensive due to additional statistical analysis | Very fast, optimized for large datasets |

3. Key Functional Differences
Feature	QIIME2	VSEARCH
Importing Data	Uses qiime tools import	Reads raw FASTQ/Fasta files directly
Denoising (Error Correction)	Uses DADA2 or deblur to denoise reads and infer amplicon sequence variants (ASVs)	No denoising, but can filter low-quality reads
OTU Clustering	No traditional OTU clustering, ASVs are preferred	Clusters sequences into OTUs based on similarity (e.g., 97% identity)
Chimera Detection	Uses DADA2's built-in chimera filtering	Uses vsearch --uchime_denovo or --uchime_ref
Taxonomy Assignment	Uses Naive Bayes classifier trained on reference databases (e.g., Greengenes, Silva)	Uses vsearch --usearch_global for taxonomy assignment by similarity
Diversity Analysis	Computes α and β diversity metrics, phylogenetic trees	Not designed for diversity analysis
Visualization	Generates .qzv files for interactive visualization using Qiime2 View	No built-in visualization tools


# QIIME2-Slurm-Protocol
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
Once this script has run it is imperitive that the `demux-paired-end.qzv` file is taken off the cluster and then imported innto to Qiime2 View. This will allow for the determination of the base cutoffs during denoising.
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
The `--p-trim-left-f`, `--p-trim-left-r`, `--p-trunc-len-f`, and `--p-trunc-len-r` must be changd before the script is run. By importing the `demux-paired-end.qzv` file in the Qiime2 View a quality report will be generated. The report will give a per base level of quality information that be used to set which bases will be trimmed based of the previous commands. The `--p-trim-left-f` corresponds to the left side of the forward reads while the `--p-trim-left-r` corresponds to the left side of the reverse reads. To ensure that the quality control succeded and did not trim too many reads take the `stats-dada2.qzv` off the cluster and import it into Qiime2 View. `rep-seqs.qzv` can also be taken off the cluster and viewed although generally there is no actual benifit in doing so. 
#### Summary
This step is essential for ensuring the accuracy and reliability of the downstream microbiome analyses by removing noise and correcting sequencing errors.
### Assigning Taxonomy
This script performs taxonomic classification of representative sequences using a pre-trained classifier, summarizes the results, and generates bar plots for visualization. It is a critical step in microbiome analysis to assign taxonomy to the observed features (ASVs) in your dataset.

    #!/bin/bash
    #SBATCH --job-name=QIIME2_taxonomy
    #SBATCH --nodes=1
    #SBATCH --ntasks-per-node=8
    #SBATCH --output=%j.output.taxonomy.txt
    #SBATCH --partition=all
    #SBATCH --time=02:00:00
    #SBATCH --mem=60G
    #SBATCH --mail-type=begin,end
    #SBATCH --mail-user=alex.kidangathazhe@gmail.com
    
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
#### Key Points
* **Taxonomic Classification**: The script uses a pre-trained classifier to assign taxonomy to the representative sequences. This step is essential for understanding the microbial composition of the samples.
* **Summary and Visualization**: The script generates a summary of the taxonomic classifications and creates bar plots to visualize the taxonomic composition, which can be reviewed using Qiime2 View (https://view.qiime2.org/).
#### Further Actions:
Take the `taxa-bar-plots.qzv` and `taxonomy.qzv` off the cluster and put them into the Qiime2 View to extract the taxonomic information. 
#### Summary
This step provides insights into the microbial communities present in your samples by assigning taxonomic labels to the features and visualizing their distribution across samples.

# VSEARCH-SLURM-Protocol
This pipeline outlines the steps to classify OTUs and assign Taxonomy using VSEARCH, on a SLURM a computing cluster. The worflow involves pair merging, quality control, dereplication, and chimera removal. This protocol only works for paired end seqeunce data and should be used to analyze defined communities. 
## General Prerequisites
This protocol is intended to be run on a SLURM based cluster, specifically the University of Oklahoma (OU) Schooner Cluster. As every cluster has its own quirks it should be understood that running this exact set of scripts in another SLURM based cluster may cause unexpected errors to occour. However, this protocol can generally be considered universal across all SLURM based clusters. The second prerequisite is the stable installation of VSEARCH prefferably as up to date as possible. The ideal method of installation is via the Anaconda package manager. Lastly, as this protocol is meant to be used on defined communities a custom database in a format acceptable to VSEARCH. 

Before starting the analysis, ensure the following prerequisites are met:
* **HPC Cluster Access**: Ensure you have access to a high-performance computing (HPC) cluster with SLURM job scheduler.
* **VSEARCH Installation**: VSEARCH should be installed and properly configured on the HPC cluster. The recommended way to install VSEARCH is via the Anaconda distribution. For installation instructions, refer to the https://github.com/torognes/vsearch.
* **Custom Database**: A custom database should be prepared that matches the defined community that is being analyzed.
* **List of Samples**: A list of samples in the correct format should also be created (see example data for example).
## Running the Protocol
### Pair Merging and Quality Statistics
The script below merges the paired and reads and extracts quality statistics that can be used to calibrate future stesps. This script operates as an array, so please make sure the numer of arrays is set to match the number of files that are put through the pipeline.

    #!/bin/bash
    #SBATCH --job-name=Vserach1
    #SBATCH --nodes=1
    #SBATCH --cpus-per-task=50
    #SBATCH --mem=200G
    #SBATCH --output=%j.output.Vsearch1
    #SBATCH --partition=all
    #SBATCH --time=8:00:00
    #SBATCH --array=1-40
    #SBATCH --mail-user=your email here
    #SBATCH --mail-type=ALL
    
    samplesheet="read_list"
    
    name=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samplesheet |  awk '{print $3}')
    file1=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samplesheet |  awk '{print $1}')
    file2=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samplesheet |  awk '{print $2}')
    file3=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samplesheet |  awk '{print $4}')
    
    
    vsearch --fastq_mergepairs $file1 --threads 40 --reverse $file2 --fastq_minovlen 50 --fastq_maxdiffs 15 --fastqout $name.merged.fastq --fastq_eeout
    
    vsearch --fastq_eestats $file1 --output $name.stats
#### Key Points
* **Pair Merging**: The script merges/assembles the paired end reads
* **Quality Summary**: The script creates a per sample quality summary.
* **Sample List**: The Script reads from the samplesheet to assign slurm array ids to each task.
#### Further Actions
Make sure to look at some of the sample quality summaries to properly set the settings for quality filtering in the upcoming steps. 
#### Summary
This step reads samples from the samplesheets and proccess them using arrays to leverage slurm's parallell computing capability. It then merges the paired end reads and the generates quality summaries to prepare for upcoming filtering. 
### Filtering and Per Sample Dereplication
The Filtering and Dereplication script is crucial because it removes noise, correct errors, and generates high-quality samples for further use. 

    #!/bin/bash
    #SBATCH --job-name=Vsearch2
    #SBATCH --nodes=1
    #SBATCH --cpus-per-task=50
    #SBATCH --mem=200G
    #SBATCH --output=%j.output.Vserach2
    #SBATCH --partition=all
    #SBATCH --time=8:00:00
    #SBATCH --array=1-40
    #SBATCH --mail-user=your email here
    #SBATCH --mail-type=ALL
    
    samplesheet="read_list"
    
    name=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samplesheet |  awk '{print $3}')
    file1=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samplesheet |  awk '{print $1}')
    file2=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samplesheet |  awk '{print $2}')
    file3=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samplesheet |  awk '{print $4}')
    file4=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samplesheet |  awk '{print $5}')
    
    vsearch --fastq_filter $file3 --fastq_maxee .5 --fastq_minlen 400 --fastq_maxlen 500 --fastq_maxns 0 --fastaout $name.filtered.fasta --fasta_width 0
    
    vsearch --derep_fulllength $file4 --strand plus --output $name.derep.fasta --sizeout --relabel $name. --fasta_width 0
#### Key Points
* **Filtering**: The script preforms quality filtering according to the given settings and returns a fasta file as a result.
* **Dereplication**: The script also preforms per sample dereplication to ensure that duplicate sequences are merged to speed up classification down the line.
#### Further Actions
Nothing special needs to be done at this step. 
#### Summary
This script fully prepares the samples to undergo OTU Clustering and Taxonomic Classification. 
### OTU Clustering and Taxonomic Classification 
This script combines all dereplicated samples and therefore does not not require the sample sheet anymore. It will then preform global dereplication, preclustering, de-novo chimera removal, reference based chimera removal, sequence extraction, OTU clustering, and Taxonomy assignment. 

    #!/bin/bash
    #SBATCH --job-name=Vsearch3
    #SBATCH --nodes=1
    #SBATCH --cpus-per-task=50
    #SBATCH --mem=200G
    #SBATCH --output=%j.output.Vsearch3
    #SBATCH --partition=all
    #SBATCH --time=8:00:00
    #SBATCH --mail-user=alex.kidangathazhe@gmail.com
    #SBATCH --mail-type=ALL
    
    cat *.derep.fasta > all.fasta
    
    echo Dereplicating across all sequences
    
    vsearch --derep_fulllength all.fasta --minuniquesize 2 --sizein --sizeout --fasta_width 0 --uc all.derep.uc --output all.derep.fasta
    
    echo Dereplication complete now preclustering
    
    vsearch --cluster_size all.derep.fasta --threads 40 --id 0.98 --strand plus --sizein --sizeout --fasta_width 0 --uc all.preclustered.uc --centroids all.preclustered.fasta
    
    echo Running chimera detection
    
    vsearch --uchime_denovo all.preclustered.fasta --sizein --sizeout --fasta_width 0 --nonchimeras all.denovo.nonchimeras.fasta 
    
    echo Running reference chimera detection
    
    vsearch --uchime_ref all.denovo.nonchimeras.fasta --threads 40 --db gold.fasta --sizein --sizeout --fasta_width 0 --nonchimeras all.ref.nonchimeras.fasta
    
    echo Extracting all non-chimeric, non-singleton, dereplicated sequences
    
    perl map.pl all.derep.fasta all.preclustered.uc all.ref.nonchimeras.fasta > all.nonchimeras.derep.fasta
    
    echo Extract all non-chimeric, non-singleton sequences in each sample 
    
    perl map.pl all.fasta all.derep.uc all.nonchimeras.derep.fasta > all.nonchimeras.fasta
    
    echo Creating OTU Table
    
    vsearch --cluster_size all.nonchimeras.fasta --threads 40 --id 0.97 --strand plus --sizein --sizeout --fasta_width 0 --uc all.clustered.uc --relabel OTU_ --centroids all.otus.fasta --otutabout all.otutab.txt
    
    echo OTU Table has been made and has been saved to all.otutab.txt
    
    echo Now Assigning Taxonomy
    
    vsearch -sintax all.otus.fasta -db gold.fasta -tabbedout tax_raw.txt -strand both -sintax_cutoff 0.5
    
    echo Taxonomy has been Assigned to tax_raw.txt
    
    echo The script has finished 
    
    echo Done
#### Key Points:
* **Merging** The script merges all dereplicated samples into a single fasta file.
* **Global Dereplication** The script then preforms dereplication again to merge duplicate sequences across samples as well as remove singletons.
* **Preclustering**: This will group sequences at 98% similarity (what ever it is set to).
* **Chimera Removal**: The script then removes chimeric sequences using both de-novo and referenced based methods.
* **Sequence Extraction**: The script will then extract the high quality filtered and non-chimeric sequences using map.pl.
* **OTU Clustering**: The remaining sequences will be clustered at 97% identity and a OTU table will be generated.
* **Taxonomy Assignment**: Taxonomy will also be assigned based on the provided custom database.
#### Further Actions:
It is suggested that the all.otutab.txt and tax_raw.txt files are taken of the cluster and processed using the provided R script to create a more usable table for figure generation and further analysis. 
#### Summary:
This script preforms the bulk of the analysis after concatonating all samples and therefore can not utilize the parallell computing potential of SLURM. 
### Table Formatting (Optional)
The R script below can be used to format the OTU table and Taxonomy table into a more usable format. 

    library(data.table)
    library(tidyverse)
    library(dplyr)
    library(stringr)
    
    Table <- fread("YOUR PATH HERE/all.otutab.txt")
    Taxonomy <- read.delim("YOUR PATH HERE/tax_raw.txt", sep="\t", header=F)
    Taxonomy$V1 = gsub(";.*","",Taxonomy$V1)
    Taxonomy$V6 = lapply(Taxonomy$V1, gsub, pattern = "OTU_", replacement = "")
    Taxonomy <- as.data.frame(Taxonomy)
    Taxonomy$V6 <- unlist(Taxonomy$V6)
    write.csv(Taxonomy, "YOUR PATH HERE/axonomy.csv", row.names = FALSE)
    Taxonomy <- read.csv("YOUR PATH HERE/Taxonomy.csv")
    names(Taxonomy)[1] <- 'OTU'
    names(Taxonomy)[2] <- 'Taxonomy'
    names(Taxonomy)[3] <- 'Useless'
    names(Taxonomy)[4] <- 'Taxonomy2'
    names(Taxonomy)[5] <- 'Useless2'
    names(Taxonomy)[6] <- 'Sort'
    Taxonomy <- Taxonomy[order(Taxonomy$Sort) , ]
    
    Taxonomy2 <- subset(Taxonomy, select=c("OTU", "Taxonomy"))
    Taxonomy2$Taxonomy = gsub("([0-9].[0-9])","",Taxonomy2$Taxonomy)
    Taxonomy2$Taxonomy = gsub("([0-9])","",Taxonomy2$Taxonomy)
    Taxonomy2$Taxonomy <- gsub("[()]", "", Taxonomy2$Taxonomy)
    Taxonomy2$Taxonomy = gsub("d:","",Taxonomy2$Taxonomy)
    Taxonomy2$Taxonomy = gsub("c:","",Taxonomy2$Taxonomy)
    Taxonomy2$Taxonomy = gsub("p:","",Taxonomy2$Taxonomy)
    Taxonomy2$Taxonomy = gsub("o:","",Taxonomy2$Taxonomy)
    Taxonomy2$Taxonomy = gsub("f:","",Taxonomy2$Taxonomy)
    Taxonomy2$Taxonomy = gsub("g:","",Taxonomy2$Taxonomy)
    Taxonomy2$Taxonomy = gsub("s:","",Taxonomy2$Taxonomy)
    
    Taxonomy3 <- as.data.frame(str_split_fixed(Taxonomy2$Taxonomy, ",", 7))
    names(Taxonomy3)[1] <- 'Kingdom'
    names(Taxonomy3)[2] <- 'Phylum'
    names(Taxonomy3)[3] <- 'Class'
    names(Taxonomy3)[4] <- 'Order'
    names(Taxonomy3)[5] <- 'Family'
    names(Taxonomy3)[6] <- 'Genus'
    names(Taxonomy3)[7] <- 'Species'
    
    Taxonomy3$OTU = Taxonomy2$OTU
    Taxonomy3 <- Taxonomy3 %>% relocate(OTU, .before = Kingdom)
    names(Table)[1] <- 'OTU'
    Table$Sort = lapply(Table$OTU, gsub, pattern = "OTU_", replacement = "")
    Table <- as.data.frame(Table)
    Table$Sort <- unlist(Table$Sort)
    write.csv(Table, "YOUR PATH HERE/OTU_Table.csv", row.names = FALSE)
    Table <- read.csv("YOUR PATH HERE/OTU_Table.csv")
    Table <- Table[order(Table$Sort) , ]
    
    OTU_Table = Table
    OTU_Table$OTU = Taxonomy3$Species
    names(OTU_Table)[1] <- 'Species'
    
    OTU_Table2 <- OTU_Table %>% group_by(Species) %>% summarise_each(funs(max)) 
#### Key Points
* **Processes Raw OTU and Taxononmy Data**: This is done by extracting only the OTU ID and then saving it.
* **Cleans Taxonomy Information**: This rmoves numerical values, special characters, and prefixes. It also splits it into hierarchial levels.
* **Replaces OTU Identifiers with Species Name**: This merges the species names with the OTU IDs and then groups the abundance by species.
#### Further Actions: 
This formatted table can be used for figure generation and further analysis. 
#### Summary:
This script just generally formats the table into a more useful format. But is optional as the actual results have been generated for use already. 
