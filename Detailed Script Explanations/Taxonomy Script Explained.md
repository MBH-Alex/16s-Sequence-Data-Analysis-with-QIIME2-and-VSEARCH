## Detailed Explanation of the Taxonomy Script

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
### Explanation
1. SLURM Job Configuration
* `#!/bin/bash`: This line specifies that the script should be run in the Bash shell.
* `#SBATCH --job-name=QIIME2_taxonomy`: This sets the name of the job to "QIIME2_taxonomy".
* `#SBATCH --nodes=1`: This specifies that the job will use 1 node.
* `#SBATCH --ntasks-per-node=8`: This sets the number of tasks per node to 8.
* `#SBATCH --output=%j.output.taxonomy.txt`: This specifies the output file for the job logs, where %j is replaced with the job ID.
* `#SBATCH --partition=all`: This sets the partition (queue) to "all".
* `#SBATCH --time=02:00:00`: This sets the maximum run time to 2 hours.
* `#SBATCH --mem=60G`: This allocates 60 GB of memory for the job.
* `#SBATCH --mail-type=begin,end`: This configures email notifications to be sent at the beginning and end of the job.
* `#SBATCH --mail-user=alex.kidangathazhe@gmail.com`: This specifies the email address to send notifications to.
2. Load Qiime2 Module
* `module load QIIME2/2021.8`: This line loads the Qiime2 module, making Qiime2 commands available for use.
3. Download Classifier
* `wget https://data.qiime2.org/2024.2/common/silva-138-99-nb-classifier.qza`: This command downloads the pre-trained SILVA 138 classifier for taxonomic classification. This classifier is used to assign taxonomy to the representative sequences.
4. Classify Sequences
* `qiime feature-classifier classify-sklearn`: This command uses the scikit-learn classifier to assign taxonomy to the sequences.
* `--i-classifier silva-138-99-nb-classifier.qza`: This specifies the input classifier file.
* `--i-reads rep-seqs.qza`: This specifies the input file containing representative sequences.
* `--o-classification taxonomy.qza`: This specifies the output file for the taxonomic classifications.
* `--p-n-jobs 8`: This uses 8 threads for parallel processing to speed up the classification.
5. Summarize Taxonomy
* `qiime metadata tabulate`: This command generates a summary of the taxonomic classification.
* `--m-input-file taxonomy.qza`: This specifies the input file containing the taxonomic classifications.
* `--o-visualization taxonomy.qzv`: This specifies the output file for the taxonomy summary visualization.
6. Create Taxa Bar Plots
* `qiime taxa barplot`: This command generates bar plots to visualize the taxonomic composition of the samples.
* `--i-table table.qza`: This specifies the input feature table file.
* `--i-taxonomy taxonomy.qza`: This specifies the input file containing the taxonomic classifications.
* `--m-metadata-file REPLACE_WITH_YOUR_METADATA_FILE`: This specifies the metadata file that maps sample IDs to metadata categories. Replace REPLACE_WITH_YOUR_METADATA_FILE with the actual path to your metadata file.
* `--o-visualization taxa-bar-plots.qzv`: This specifies the output file for the taxa bar plots visualization.
### Explanation of Output Files
`taxonomy.qza`
* Description: This file contains the taxonomic classifications of the representative sequences. It is a Qiime2 artifact that stores the results of the taxonomy assignment process.
* Usage: This file is used as input for generating visual summaries and bar plots. It can be further analyzed or visualized to understand the taxonomic composition of your samples.

`2. taxonomy.qzv`
* Description: This file is a visualization of the taxonomic classifications stored in taxonomy.qza. It is a Qiime2 visualization file that provides a summary of the taxonomic assignments.
Contents:
* Tabulated Taxonomy: A table showing each feature (ASV) and its assigned taxonomy.
* Interactive Visualization: Allows for exploration of the taxonomic assignments interactively.
* Usage: View this file using Qiime2 View (https://view.qiime2.org/) to inspect and explore the taxonomic classifications. This helps in understanding which taxa are present in your samples and their relative abundances.
`3. taxa-bar-plots.qzv`
* Description: This file contains bar plots that visualize the taxonomic composition of the samples. It is a Qiime2 visualization file that provides a graphical representation of the taxa present in each sample.
Contents:
* Bar Plots: Bar plots showing the relative abundance of different taxa across samples. The plots are interactive and can be filtered by taxonomic level and sample metadata.
* Usage: View this file using Qiime2 View (https://view.qiime2.org/) to explore the taxonomic composition of your samples. This visualization helps in comparing the microbial communities between different samples or groups and identifying dominant taxa.
