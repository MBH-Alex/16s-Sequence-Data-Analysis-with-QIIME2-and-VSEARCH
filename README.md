# QIIME2-Slurm-Protocol-Scaria-Lab
This protocol outlines the steps for conducting a comprehensive microbiome analysis using Qiime2, on a SLURM computing cluster. The workflow includes data import, quality control, feature table construction, phylogenetic analysis, diversity metrics computation, taxonomic classification, and optional differential abundance analysis using ANCOM. This protocol is optimized for processing paired-end sequence data.
## General Prerequisites
This protocol is intended to be run on a SLURM based cluster, specifically the University of Oklahoma (OU) Schooner Cluster. As every cluster has its own quirks it should be understood that running this exact set of scripts in another SLURM based cluster may cause unexpected errors to occour. However, this protocol can generally be considered universal across all SLURM based clusters. 
The second prerequisite is a stable installation of QIIME2, prefferably as up to date as possible. If this is being run on the Schooner Cluster, this requirment has already been taken care of as the Schooner Cluster has several QIIME2 modules although they are quite out of date. 

Before starting the analysis, ensure the following prerequisites are met:
* **HPC Cluster Access**:Ensure you have access to a high-performance computing (HPC) cluster with SLURM job scheduler.
* **Qiime2 Installation**:Qiime2 should be installed and properly configured on the HPC cluster. The recommended way to install Qiime2 is via the Anaconda distribution. For installation instructions, refer to the Qiime2 Installation Guide. If running this on the Schooner cluster the module will suffice. 
* **Data Preparation**: Prepare your paired-end sequence data in the Casava 1.8 single-lane per sample format. Ensure that your data is organized in a directory structure suitable for Qiime2 import.
* **Metadata file**: Ensure you have a metadata file (e.g., Metadata.txt) that follows Qiime2's metadata format. This file will be used for mapping sample IDs to metadata categories.
