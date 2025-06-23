commands:

It is recommended to start a srun session if you are on biodiversity:
srun --partition=short --cpus-per-task=8 --mem=30G --pty bash

the package amplicon_seq.sh contains 8 commands

To set up the environment:
./set_up_env.sh $NAME_OF_YOUR_ENVIRONMENT_FOR_AMPLICON_SEQ_ANALYSIS

To run amplicon seq package:

activate environment:
conda activate $NAME_OF_YOUR_ENVIRONMENT_FOR_AMPLICON_SEQ_ANALYSIS

#make work directory on scratch
./amplicom_seq.sh make_work_dir $NAME_OF_THE_SUBDIRECTORY_ON_SCRATCH

#base-calling
sbatch ./amplicom_seq.sh basecalling takes two inputs:
sbatch ./amplicom_seq.sh basecalling $NAME_OF_THE_SUBDIRECTORY_ON_SCRATCH $BATCH_SIZE #submit job, but just run the selected function not the entire script
#demultiplx

sbatch ./amplicom_seq.sh demultiplex $NAME_OF_THE_SUBDIRECTORY_ON_SCRATCH
#NanoPlot_QC

sbatch ./amplicom_seq.sh NanoPlot_QC takes three inputs:

sbatch ./amplicom_seq.sh NanoPlot_QC $NAME_OF_THE_SUBDIRECTORY_ON_SCRATCH $min_len $max_len

#Porechop for adaptor and barcode trimming
sbatch ./amplicon_seq.sh Porechop_trim $NAME_OF_THE_SUBDIRECTORY_ON_SCRATCH

#Chopper for quality trimming
sbatch ./amplicon_seq.sh Chopper_QT $NAME_OF_THE_SUBDIRECTORY_ON_SCRATCH

#Amplicon Sorter
sbatch ./amplicon_seq.sh ampliconsorter $NAME_OF_THE_SUBDIRECTORY_ON_SCRATCH