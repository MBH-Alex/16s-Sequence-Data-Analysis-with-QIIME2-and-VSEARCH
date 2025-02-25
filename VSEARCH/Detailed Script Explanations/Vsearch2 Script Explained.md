---
Status: 
tags:
  - note
Links: 
Created: 2025-02-25T08:52:08
---
## Detailed Explanation of the Vsearch1 Script
---
``` shell
#!/bin/bash
#SBATCH --job-name=Vsearch2
#SBATCH --nodes=1
#SBATCH --cpus-per-task=50
#SBATCH --mem=200G
#SBATCH --output=%j.output.Vsearch2
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

vsearch --derep_fulllength $file4 --strand plus --output $name.derep.fasta --sizeout --relabel $name. --fasta_width 0>)
```
### Explanation
1. SLURM Job Configuration
 - `#!/bin/bash`: This line specifies that the script should be executed using the Bash shell.
 - `#SBATCH --job-name=Vsearch1`: Sets the job name as "Vsearch1"
 - `#SBATCH --nodes=1`: Requests one compute node for execution
 - `#SBATCH --cpus-per-task=50`: Allocates 50 CPU cores per task for parallel processing (change as needed).
 - `#SBATCH --mem=200G`: Requests 200 Gigabytes of RAM for the job (change as needed).
 - `#SBATCH --output=%j.output.Vsearch2`: Defines the output file for the job logs, where `%j` will be replaced with the job ID.
 - `#SBATCH --partition=all`: Specifies the partition (queue) to run the job. "all" implies that it can run on any available partition.
 - `#SBATCH --array=1-40`: This enables job array functionality, meaning 40 separate tasks will be executed in parallel (one for each sample). Each task is identified by `$SLURM_ARRAY_TASK_ID`, which ranges from `1` to `40`.
 - `#SBATCH --mail-user=your email here #SBATCH --mail-type=ALL`: Configures email notifications for all job status updates (start, completion, failure, etc.). The user must replace "your email here" with a valid email address.
 Important Notes: The resources being requested (CPUs and RAM and assigned to each of the array tasks so requesting to much will decrease the number of jobs running in parallel.
 1. Activating VSEARCH
It is highly recommended that VSEARCH be run using a Conda or Mamba environment and most clusters the saftest choice is to activate the environment and then `sbatch` the SLURM script. 
1. Sample Information
- `samplesheet="read_list"`: Specifies the sample sheet file (`read_list`), which contains information about sample names and corresponding FASTQ files.
- `name=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samplesheet |  awk '{print $3}') file1=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samplesheet |  awk '{print $1}') file2=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samplesheet |  awk '{print $2}') file3=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samplesheet |  awk '{print $4}') file4=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samplesheet |  awk '{print $5}')`:  Extracts the sample name and file paths from the sample sheet (`read_list`). Uses `sed -n "$SLURM_ARRAY_TASK_ID"p` to fetch the line corresponding to the current array job. Uses `awk` to extract specific columns: `{print $1} → Forward read file`. `{print $2} → Reverse read file`. `{print $3} → Sample Name.` `{print $4} → Merged File`.  `{print $5} → Dereplicated/Filtered sequence file (file4)`.
1. Quality Filtering of Samples
- `vsearch --fastq_filter $file3 --fastq_maxee .5 --fastq_minlen 400 --fastq_maxlen 500 --fastq_maxns 0 --fastaout $name.filtered.fasta --fasta_width 0`: Filters raw sequences from `$file3` based on quality and length criteria.
	- `--fastq_filter $file3` → Specifies the input FASTQ file (filtered sequences).
	- `--fastq_maxee .5` → Sets the maximum expected error rate to 0.5 (low-error reads only).
	- `--fastq_minlen 400` → Retains reads with a minimum length of 400 bases.
	- `--fastq_maxlen 500` → Retains reads with a maximum length of 500 bases.
	- `--fastq_maxns 0` → Removes reads containing any ambiguous (N) bases.
	- `--fastaout $name.filtered.fasta` → Outputs the filtered sequences in FASTA format.
	- `--fasta_width 0` → Writes sequences in single-line format for better readability.
1. Dereplication of Sequences
- `vsearch --derep_fulllength $file4 --strand plus --output $name.derep.fasta --sizeout --relabel $name. --fasta_width 0`: Dereplicates sequences, meaning identical sequences are collapsed into a single entry.
	-  `--derep_fulllength $file4` → Reads sequences from `$file4` and performs full-length dereplication.
	- `--strand plus` → Considers only the forward strand for deduplication.
	- `--output $name.derep.fasta` → Saves the dereplicated sequences in FASTA format.
	- `--sizeout` → Appends size annotations to the output file (number of duplicate sequences collapsed).
	- `--relabel $name.` → Renames sequences, prefixing them with the sample name for better tracking.
	- `--fasta_width 0` → Writes sequences in single-line format for readability.
### General Comments and Considerations
- **Parallel Processing via SLURM Array Jobs**:
    - The script processes **40 different samples simultaneously**.
    - Each task **reads different lines** from `read_list` to extract sample-specific files.
- **Computational Resource Usage**:
    - **50 CPU cores** and **200GB RAM** are allocated per task, making this script highly resource-intensive.
    - The **filtering and dereplication steps** can be computationally expensive for large datasets.
- **File Naming & Output Management**:
    - The **filtered sequences** are saved as **`$name.filtered.fasta`**.
    - The **dereplicated sequences** are saved as **`$name.derep.fasta`**.
    - The **`--sizeout` flag** ensures that **abundance information** is retained.
- **Expected Error Rate Filtering (`--fastq_maxee`)**:
    - The **expected error rate (`--fastq_maxee 0.5`)** is strict.
    - Lowering this value (e.g., `0.2`) would result in **higher-quality reads**, but fewer sequences.
    - Increasing it (e.g., `1.0`) would **retain more reads** but may introduce sequencing errors.
- **Read Length Cutoff (`--fastq_minlen` & `--fastq_maxlen`)**:
    - This script **removes sequences shorter than 400bp or longer than 500bp**.
    - Adjust these values based on **target amplicon size**.
- **Dereplication Strategy (`--derep_fulllength`)**:
    - This **collapses identical sequences**, reducing computational complexity in downstream analyses.
    - If reads are **already quality-filtered**, this step ensures that only unique sequences are retained.
- **Strand-Specific Processing (`--strand plus`)**:
    - This ensures that **only the forward strand** is considered for dereplication.
    - If the dataset contains **both forward and reverse complement sequences**, using `--strand both` might be beneficial.