## Detailed Explanation of the Import Script

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
### Explanation
1. SLURM Job Configuration
* `#!/bin/bash`: This line specifies that the script should be run in the Bash shell.
* `#SBATCH --job-name=QIIME2_import`: This sets the name of the job to "QIIME2_import".
* `#SBATCH --nodes=1`: This specifies that the job will use 1 node.
* `#SBATCH --ntasks-per-node=8`: This sets the number of tasks per node to 8.
* `#SBATCH --output=%j.output.import.txt`: This specifies the output file for the job logs, where %j is replaced with the job ID.
* `#SBATCH --partition=batch`: This sets the partition (queue) to "batch".
* `#SBATCH --time=01:00:00`: This sets the maximum run time to 1 hour.
* `#SBATCH --mail-type=begin,end`: This configures email notifications to be sent at the beginning and end of the job.
* `#SBATCH --mail-user=your_email`: This specifies the email address to send notifications to. **MUST BE REPLACED WITH YOUR EMAIL TO FUNCTION**
2. Loading QIIME2 Module
* `module load QIIME2/2021.8`: This loads the QIIME2 module maintained by the cluster
3. Importing Data
* `qiime tools import`: This command imports data into Qiime2.
* `--type 'SampleData[PairedEndSequencesWithQuality]'`: This specifies the type of data being imported. Here, it's paired-end sequences with quality scores.
* `--input-path YOUR DIRECOTRY HERE`: This specifies the path to the input directory containing the FASTQ files. **MUST BE REPLACED WITH THE DIRECT PATH TO YOUR DIRECTORY HERE**
* `--input-format CasavaOneEightSingleLanePerSampleDirFmt`: This specifies the input format. In this case, the data is in the Casava 1.8 format.
* `--output-path demux-paired-end.qza`: This specifies the output file path for the imported data in Qiime2 artifact format (.qza).
4. Summarizing Demultiplexed Data
* `qiime demux summarize`: This command generates summary statistics and visualizations for the demultiplexed data.
* `--i-data demux-paired-end.qza`: This specifies the input file, which is the imported data from the previous step.
* `--o-visualization demux-paired-end.qzv`: This specifies the output file for the summary visualization in Qiime2 visualization format (.qzv).
### General Comments
As mentioned in the README it is crucial that the `demux-paired-end.qzv` is taken off the cluster and viewed in Qiime2 View to properly set the trimming parameter in the next step. If this step causes errors check the directory containing the samples as well as the input format of your samples. 
