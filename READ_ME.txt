USEAGE:

This repository contains three scripts for AMPLICON SEQ processing: set_up_evn.sh, amplicon_seq_GPU.sh, amplicon_seq_array.sh

#Set up env

To set up your environment for amplicon seq analysis, run set_up_evn.sh $ENV_NAME $USER $WORKDIR
The script expects THREE input variables. Please supply 
          the name of your environment, 
          your rbge user name for setting up directories, AND 
          the subdirectory on scratch where the project will be carried out



after setting up the environment, it also generates a series of directories within your work subdirectory:

#organize directories
mkdir $HOME/scratch/$work_dir/data
mkdir $HOME/scratch/$work_dir/data/pod5
#Create a folder for scripts
mkdir $HOME/scratch/$work_dir/scripts
#Create a folder for $subdir
mkdir $HOME/scratch/$work_dir/results
#Create folders under result folder for each program
mkdir $HOME/scratch/$work_dir/results/amp1-dorado-basecalling
mkdir $HOME/scratch/$work_dir/results/amp2-dorado-demultiplex
mkdir $HOME/scratch/$work_dir/results/amp3-samtools-fastq
mkdir $HOME/scratch/$work_dir/results/amp4-nanoplot
mkdir $HOME/scratch/$work_dir/results/amp5-porechop
mkdir $HOME/scratch/$work_dir/results/amp6-chopper
mkdir $HOME/scratch/$work_dir/results/amp7-ampliconsorter

the most important ones are data and results directories. 
make sure you load the pod5 data onto $HOME/scratch/$work_dir/data/pod5


#Amplicon Seq with GPU

the first two steps--basecalling and demultiplexing--require GPU
To run amplicon_seq_GPU.sh, you need to first go to the end of the script and provide the following variables:

USER=zedchen #same as previous user name
ENV=minion #name of your environment
WORKDIR=zed_chen/amplicon_seq #

After setting up the variables and saved the pod5 data, run the script: sbatch amplicon_seq_GPU.sh

#Amplicon Seq with Array

the following 5 steps--samtools, NanoPlot_QC, Porechop_trim, Chopper_QT, and ampliconsorter--are submitted as arrays:

To run amplicon_seq_GPUarray.sh, you need to first check your $HOME/scratch/$work_dir/results/amp2-dorado-demultiplex directory and see how the files are numbered:
for instance, my test files are from SQK-NBD114-96_barcode01.bam to SQK-NBD114-96_barcode93.bam
then modify the #SBATCH --array=1-93 command on top to match the array


Then go to the end of the script and provide the following variables:

USER=zedchen #same as previous user name
ENV=minion #name of your environment
WORKDIR=zed_chen/amplicon_seq #
FILE_PREFIX=SQK-NBD114-96_barcode #THE PREFIX OF THE FILES (do they always stay the same?)

you can also modify the following parameters:

min_len=200 #NanoPlot_QC
max_len=10000 #NanoPlot_QC
SLURM_CPUS_PER_TASK=8 #speed#

can also ask for more memory and more CUPs per task, according to your need

then run the script: sbatch amplicon_seq_array.sh
The final outputs should be in $HOME/scratch/$work_dir/results/amp7-ampliconsorter