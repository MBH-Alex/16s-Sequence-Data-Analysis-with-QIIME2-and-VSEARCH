---
Status: 
tags:
  - note
Links: 
Created: 2025-02-25T20:01:34
---
## Detailed Script Explanations
---
```shell
#!/bin/bash
#SBATCH --job-name=Vsearch3
#SBATCH --nodes=1
#SBATCH --cpus-per-task=50
#SBATCH --mem=200G
#SBATCH --output=%j.output.Vsearch3
#SBATCH --partition=all
#SBATCH --time=8:00:00
#SBATCH --mail-user=your email here
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
```
### Explanation
1. SLURM Job Configuration:
- `#!/bin/bash`: This line specifies that the script should be executed using the Bash shell.
- `#SBATCH --job-name=Vsearch1`: Sets the job name as "Vsearch3"
- `#SBATCH --nodes=1`: Requests one compute node for execution
- `#SBATCH --cpus-per-task=50`: Allocates 50 CPU cores per task for parallel processing (change as needed).
- `#SBATCH --mem=200G`: Requests 200 Gigabytes of RAM for the job (change as needed).
- `#SBATCH --output=%j.output.Vsearch3`: Defines the output file for the job logs, where `%j` will be replaced with the job ID.
- `#SBATCH --partition=all`: Specifies the partition (queue) to run the job. "all" implies that it can run on any available partition.
- `#SBATCH --mail-user=your email here #SBATCH --mail-type=ALL`: Configures email notifications for all job status updates (start, completion, failure, etc.). The user must replace "your email here" with a valid email address.
1. Activating VSEARCH
It is highly recommended that VSEARCH be run using a Conda or Mamba environment and most clusters the saftest choice is to activate the environment and then `sbatch` the SLURM script. 
1. Concatenating Dereplicated Sequences
- `cat *.derep.fasta > all.fasta`
- This command concatenates (`cat`) all `.derep.fasta` files from previous processing into a single `all.fasta` file.
- Ensures that all dereplicated sequences from different samples are merged into one dataset for further clustering and chimera detection.
1. Dereplication Across All Seuences
- `echo Dereplicating across all sequences vsearch --derep_fulllength all.fasta --minuniquesize 2 --sizein --sizeout --fasta_width 0 --uc all.derep.uc --output all.derep.fasta` 
- Purpose: Removes duplicate sequences across all samples to avoid redundancy in downstream processing.
- Flags Explanation:
    - `--derep_fulllength all.fasta` → Performs full-length sequence dereplication.
    - `--minuniquesize 2` → Removes singletons (sequences appearing only once).
    - `--sizein --sizeout` → Preserves size information (sequence abundance).
    - `--fasta_width 0` → Ensures sequences are written in single-line FASTA format.
    - `--uc all.derep.uc` → Outputs a cluster file with dereplication details.
    - `--output all.derep.fasta` → Saves the dereplicated sequences to `all.derep.fasta`.`
1. Preclustering of Dereplicated Samples
- `echo Dereplication complete now preclustering vsearch --cluster_size all.derep.fasta --threads 40 --id 0.98 --strand plus --sizein --sizeout --fasta_width 0 --uc all.preclustered.uc --centroids all.preclustered.fasta`
-  Purpose: Groups similar sequences together based on a **98% identity threshold** to reduce redundancy and improve efficiency in chimera detection.
- Flags Explanation:
    - `--cluster_size all.derep.fasta` → Clusters sequences based on their abundance.
    - `--threads 40` → Uses 40 CPU cores for parallel processing.
    - `--id 0.98` → Sets a **98% sequence similarity threshold** for clustering.
    - `--strand plus` → Considers only the forward strand.
    - `--sizein --sizeout` → Retains sequence abundance information.
    - `--fasta_width 0` → Outputs sequences in single-line format.
    - `--uc all.preclustered.uc` → Outputs a cluster file detailing the preclustering process.
    - `--centroids all.preclustered.fasta` → Saves representative sequences (centroids) for each cluster.
1. Chimera Detection (De Novo)
- `echo Running chimera detection vsearch --uchime_denovo all.preclustered.fasta --sizein --sizeout --fasta_width 0 --nonchimeras all.denovo.nonchimeras.fasta`
- Purpose: Identifies and removes chimeric sequences (artifacts created during PCR amplification).
- Flags Explanation:
    - `--uchime_denovo all.preclustered.fasta` → Performs **de novo** chimera detection.
    - `--sizein --sizeout` → Preserves sequence abundance information.
    - `--fasta_width 0` → Outputs sequences in a single-line format.
    - `--nonchimeras all.denovo.nonchimeras.fasta` → Saves the filtered, non-chimeric sequences.
1. Reference-Based Chimera Detection 
- `echo Running reference chimera detection vsearch --uchime_ref all.denovo.nonchimeras.fasta --threads 40 --db gold.fasta --sizein --sizeout --fasta_width 0 --nonchimeras all.ref.nonchimeras.fasta`
-  Purpose: Further refines the dataset by detecting chimeras against a **reference database (`gold.fasta`)**.
- Flags Explanation:
    - `--uchime_ref all.denovo.nonchimeras.fasta` → Runs reference-based chimera detection.
    - `--threads 40` → Uses 40 CPU threads for faster processing.
    - `--db gold.fasta` → Uses **gold.fasta** as a reference database for known chimeras.
    - `--sizein --sizeout` → Retains sequence abundance information.
    - `--fasta_width 0` → Outputs sequences in a single-line format.
    - `--nonchimeras all.ref.nonchimeras.fasta` → Saves final non-chimeric sequences.
1. Extracting Non-Chimeric, Non-Singleton, Dereplicated Sequences
- `echo Extracting all non-chimeric, non-singleton, dereplicated sequences perl map.pl all.derep.fasta all.preclustered.uc all.ref.nonchimeras.fasta > all.nonchimeras.derep.fasta`
- Uses a Perl script (`map.pl`) to filter out sequences that:
	- Are non-chimeric.
	- Have more than one occurrence.
	- Are dereplicated.
1. Extracting Non-Chimeric, Non-Singleton Sequences for Each Sample
- `echo Extract all non-chimeric, non-singleton sequences in each sample  perl map.pl all.fasta all.derep.uc all.nonchimeras.derep.fasta > all.nonchimeras.fasta`
- Ensures that only high-quality sequences are retained for each sample.
1. Creating an OTU Table
- `echo Creating OTU Table vsearch --cluster_size all.nonchimeras.fasta --threads 40 --id 0.97 --strand plus --sizein --sizeout --fasta_width 0 --uc all.clustered.uc --relabel OTU_ --centroids all.otus.fasta --otutabout all.otutab.txt`
- Purpose: Groups sequences into **Operational Taxonomic Units (OTUs)** at **97% similarity**.
- Flags Explanation:
    - `--cluster_size all.nonchimeras.fasta` → Clusters sequences into OTUs.
    - `--id 0.97` → Sets a **97% identity threshold** for OTUs.
    - `--relabel OTU_` → Prefixes OTU names with `OTU_` for clarity.
    - `--centroids all.otus.fasta` → Saves representative sequences of each OTU.
    - `--otutabout all.otutab.txt` → Creates an **OTU table**, summarizing sequence abundance.
1. Assigning Taxonomy
- `echo Now Assigning Taxonomy vsearch -sintax all.otus.fasta -db gold.fasta -tabbedout tax_raw.txt -strand both -sintax_cutoff 0.5`
- Purpose: Assigns taxonomy to OTUs using the **SINTAX classifier**.
- Flags Explanation:
    - `-sintax all.otus.fasta` → Runs SINTAX on OTU representative sequences.
    - `-db gold.fasta` → Uses `gold.fasta` as the reference taxonomy database.
    - `-tabbedout tax_raw.txt` → Outputs results to `tax_raw.txt`.
    - `-strand both` → Considers both strands for classification.
    - `-sintax_cutoff 0.5` → Sets a confidence threshold of 50%.
### General Comments and Considerations
- This script concatenates all dereplicated samples and then runs the rest of the pipeline on them. 
- Optionally, use the R Script to format the tables to a more readable format. 