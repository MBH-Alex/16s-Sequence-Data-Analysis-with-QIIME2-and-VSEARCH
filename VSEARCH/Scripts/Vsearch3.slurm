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
