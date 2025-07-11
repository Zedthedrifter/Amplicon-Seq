#!/bin/bash
#SBATCH --job-name="amplicon_seq_GPU"
#SBATCH --export=ALL
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1 #ask for one. without this line I'll get this error message: [error] CUDA device requested but no devices found.
#SBATCH --mem=32G #CHANGE TO THE AMOUNT OF MEM YOU NEED


function basecalling {


work_dir=$1
batchsize=$2
pod5s=$HOME/scratch/$work_dir/data/pod5 #input pod5 data directory: pod5
#
ourdir=$HOME/scratch/$work_dir/results/amp1-dorado-basecalling

echo 'basecalling for' ${work_dir}', batch size:'${batchsize} 'input data: '${pod5s}

dorado basecaller \
        --batchsize $batchsize \
        $MODEL \
        $pod5s/ \
        --kit-name SQK-NBD114-96 \
        > $ourdir/amp1_all_basecall.bam



}

function demultiplex {

work_dir=$1
INDIR=$HOME/scratch/$work_dir/results/amp1-dorado-basecalling
OUTDIR=$HOME/scratch/$work_dir/results/amp2-dorado-demultiplex

echo 'demultiplex for' ${work_dir}

dorado demux \
        --output-dir $OUTDIR \
        --no-classify $INDIR/amp1_all_basecall.bam

}



# Check command-line argument and call the function
function main {

USER=$1 #
env_name=$2 #same as your previous input
WORKDIR=$3 #on scratch

#base_calling
BATCH_SIZE=$4
basecalling $WORKDIR $BATCH_SIZE
#DEMULTIPLEXING
demultiplex $WORKDIR
}


#add PATH to dorado
export PATH=$PATH:$HOME/scratch/apps/dorado-0.4.1-linux-x64/bin
export PATH=$PATH:$HOME/scratch/apps/dorado-0.4.1-linux-x64
export LD_LIBRARY_PATH=$HOME/scratch/apps/dorado-0.4.1-linux-x64/lib:$LD_LIBRARY_PATH
MODEL=$HOME/scratch/apps/dorado-0.4.1-linux-x64/model/dna_r10.4.1_e8.2_400bps_hac\@v4.2.0/

#USER INPUTS (CAN ALSO MAKE IT INTERACTIVE, LIKE INPUT FROM TERMINAL INSTEAD OF IN THE SCRIPT, IF YOU PREFER)
USER=zedchen #must change
ENV=amp_test #might change
WORKDIR=zed_chen/amp_test #must change
BATCH_SIZE=64 #batch size for cuda


main $USER $ENV $WORKDIR $BATCH_SIZE #CHANGE BOTH TO YOUR ACTUAL USER NAME, ENV NAME, AND WORK DIRECTORY ON SCRATCH





