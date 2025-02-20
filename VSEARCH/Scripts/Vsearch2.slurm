#!/bin/bash
#SBATCH --job-name=Vsearch2
#SBATCH --nodes=1
#SBATCH --cpus-per-task=50
#SBATCH --mem=200G
#SBATCH --output=%j.output.Vsearch3
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
