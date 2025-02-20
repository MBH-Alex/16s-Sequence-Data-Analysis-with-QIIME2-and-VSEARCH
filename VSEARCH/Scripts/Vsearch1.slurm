#!/bin/bash
#SBATCH --job-name=Vsearch1
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

