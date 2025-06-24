#!/bin/bash
#SBATCH --job-name="amplicon_seq_${1}"
#SBATCH --export=ALL
#SBATCH --cpus-per-task=8
#SBATCH --array=1-95 #change it to the number of array in amp2 directory. when I'm testing, I got SQK-NBD114-96_barcode01.bam to SQK-NBD114-96_barcode93.bam. formatted as 01,02,etc. if you have over 100 samples, need to reformat for that.
#SBATCH --mem=32G #change it to the amount of memory you need
#SBATCH --chdir=$HOME/scratch/$WORKDIR #not really necessary


#parallel
function samtools_fastq {
echo 'running samtools for ${work_dir}'
work_dir=$1
FILE_PREFIX=$2
INDIR=$HOME/scratch/$work_dir/results/amp2-dorado-demultiplex
OUTDIR=$HOME/scratch/$work_dir/results/amp3-samtools-fastq
SLURM_ARRAY_TASK_ID=$(printf "%02d" "$SLURM_ARRAY_TASK_ID")

#get all the rests, regardless of pairing etc.
samtools fastq -@ $SLURM_CPUS_PER_TASK $INDIR/${FILE_PREFIX}${SLURM_ARRAY_TASK_ID}.bam > $OUTDIR/samtools_${SLURM_ARRAY_TASK_ID}.fastq

echo 'samtools_fastq Job completed'
}

#parallel
function NanoPlot_QC {

work_dir=$1
minlen=$2
maxlen=$3

INDIR=$HOME/scratch/$work_dir/results/amp3-samtools-fastq
OUTDIR=$HOME/scratch/$work_dir/results/amp4-nanoplot
SLURM_ARRAY_TASK_ID=$(printf "%02d" "$SLURM_ARRAY_TASK_ID")

echo 'running NanoPlot QC' $OUTDIR $minlen $maxlen

NanoPlot -t 2 --fastq $INDIR/samtools_${SLURM_ARRAY_TASK_ID}.fastq \
  --outdir $OUTDIR/NanoPlot_bc${SLURM_ARRAY_TASK_ID}  \
  --minlength $minlen --maxlength $maxlen --plots dot --legacy hex

echo 'NanoPlot QC Job completed'

}

#parallel
function Porechop_trim {

work_dir=$1

INDIR=$HOME/scratch/$work_dir/results/amp3-samtools-fastq
OUTDIR=$HOME/scratch/$work_dir/results/amp5-porechop

SLURM_ARRAY_TASK_ID=$(printf "%02d" "$SLURM_ARRAY_TASK_ID")
echo 'running Porechop to trim barcode and adaptor'

porechop -t 4 --extra_end_trim 0 -i $INDIR/samtools_${SLURM_ARRAY_TASK_ID}.fastq -o $OUTDIR/porechop.bc${SLURM_ARRAY_TASK_ID}.fastq

echo 'Porechop_trim Job completed'

}

#parallel
function Chopper_QT { 

work_dir=$1

INDIR=$HOME/scratch/$work_dir/results/amp5-porechop
OUTDIR=$HOME/scratch/$work_dir/results/amp6-chopper
SLURM_ARRAY_TASK_ID=$(printf "%02d" "$SLURM_ARRAY_TASK_ID")

echo 'running chopper for quality trimming'

chopper -q 10 -l 500 -i $INDIR/porechop.bc${SLURM_ARRAY_TASK_ID}.fastq > $OUTDIR/chopper.bc${SLURM_ARRAY_TASK_ID}.fastq

echo 'Chopper Job completed'
}

#parallel
function ampliconsorter {

work_dir=$1


INDIR=$HOME/scratch/$work_dir/results/amp6-chopper
OUTDIR=$HOME/scratch/$work_dir/results/amp7-ampliconsorter
AMPLICON_SORTER_PATH=$HOME/scratch/apps/amplicon_sorter
SLURM_ARRAY_TASK_ID=$(printf "%02d" "$SLURM_ARRAY_TASK_ID")


echo 'running ampliconsorter to create consensus'

$HOME/projects/rbge/$USER/env/$env_name/bin/python3 $AMPLICON_SORTER_PATH/amplicon_sorter.py \
        -i $INDIR/chopper.bc${SLURM_ARRAY_TASK_ID}.fastq \
        -o $OUTDIR/ampsorter.bc${SLURM_ARRAY_TASK_ID}.def \
        -np $SLURM_CPUS_PER_TASK \
        -ar -maxr 570000

echo 'ampliconsorter Job completed'
}



# Check command-line argument and call the function
function main {

USER=$1 #
env_name=$2 #same as your previous input
WORKDIR=$3 #on scratch

#---------------------------------------
#samtools 
samtools_fastq $WORKDIR ${FILE_PREFIX}
#NanoPlot_QC
min_len=$4
max_len=$5
NanoPlot_QC $WORKDIR $min_len $max_len 
#Porechop
Porechop_trim $WORKDIR
#Chopper
Chopper_QT $WORKDIR
#ampliconsorter
ampliconsorter $WORKDIR
}


#add PATH to dorado
export PATH=$PATH:$HOME/scratch/apps/dorado-0.4.1-linux-x64/bin
export PATH=$PATH:$HOME/scratch/apps/dorado-0.4.1-linux-x64
export LD_LIBRARY_PATH=$HOME/scratch/apps/dorado-0.4.1-linux-x64/lib:$LD_LIBRARY_PATH
MODEL=$HOME/scratch/apps/dorado-0.4.1-linux-x64/model/dna_r10.4.1_e8.2_400bps_hac\@v4.2.0/

#---------------------------------------------------------------------------------------------------------------------------------
#USER INPUTS (CAN ALSO MAKE IT INTERACTIVE, LIKE INPUT FROM TERMINAL INSTEAD OF IN THE SCRIPT, IF YOU PREFER)
USER=zedchen
ENV=minion
WORKDIR=zed_chen/amp_test
FILE_PREFIX=SQK-NBD114-96_barcode
min_len=200
max_len=10000
SLURM_CPUS_PER_TASK=8


main $USER $ENV $WORKDIR $min_len $max_len #CHANGE BOTH TO YOUR ACTUAL USER NAME, ENV NAME, AND WORK DIRECTORY ON SCRATCH





