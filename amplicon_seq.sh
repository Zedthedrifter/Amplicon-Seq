#!/bin/bash
#SBATCH --job-name="amplicon_seq_${1}"
#SBATCH --export=ALL
#SBATCH --partition=short
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G #change it to the amount of memory you need

#add universal variable: env name and your USER NAME///you need to change this by yourself
USER=zedchen #change it to your username
env_name=minion #same as your previous input

#add PATH to dorado
export PATH=$PATH:$HOME/scratch/apps/dorado-0.4.1-linux-x64/bin
export PATH=$PATH:$HOME/scratch/apps/dorado-0.4.1-linux-x64
export LD_LIBRARY_PATH=$HOME/scratch/apps/dorado-0.4.1-linux-x64/lib:$LD_LIBRARY_PATH
MODEL=$HOME/scratch/apps/dorado-0.4.1-linux-x64/model/dna_r10.4.1_e8.2_400bps_hac\@v4.2.0/

#Create working directory under scratch
function make_work_dir {
#in your scratch directory, make your project directory
#this function should be run one and only once
work_dir=$1

#organize directories
mkdir $HOME/scratch/$work_dir/data
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
}

function basecalling {


work_dir=$1
batchsize=$2
pod5s=$HOME/scratch/$work_dir/data/pod5 #input pod5 data directory
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

echo 'demultiplex for ${work_dir}'

dorado demux \
        --output-dir $OUTDIR \
        --no-classify $INDIR/amp1_all_basecall.bam

}

function samtools_fastq { #for faster processing, use the array version to submit sbatch. otherwise, just a for loop

echo 'running samtools for ${work_dir}'
work_dir=$1
INDIR=$HOME/scratch/$work_dir/results/amp2-dorado-demultiplex
OUTDIR=$HOME/scratch/$work_dir/results/amp3-samtools-fastq
for bam in $(ls $INDIR/*bam)
do
samtools fastq -0 /dev/null $bam > ${bam/bam/fastq} #just iterating over all bam files
done

echo 'Job completed'
}

function NanoPlot_QC {

work_dir=$1
minlen=$2
maxlen=$3

INDIR=$HOME/scratch/$work_dir/results/amp3-samtools-fastq
OUTDIR=$HOME/scratch/$work_dir/results/amp4-nanoplot


echo 'running NanoPlot QC' $OUTDIR $minlen $maxlen

for fastq in $(ls $INDIR/*fastq)
do
fastq=$(echo $fastq|awk -F/ '{print $NF}') #just the file name without the full path
echo $fastq
NanoPlot -t 2 --fastq $INDIR/${fastq} \
  --outdir $OUTDIR/NanoPlot_qc_${fastq} \
  --minlength $minlen --maxlength $maxlen --plots dot --legacy hex
done

echo 'Job completed'

}

function Porechop_trim {

work_dir=$1
INDIR=$HOME/scratch/$work_dir/results/amp3-samtools-fastq
OUTDIR=$HOME/scratch/$work_dir/results/amp5-porechop
echo 'running Porechop to trim barcode and adaptor'

for fastq in $(ls $INDIR/*fastq)
do
fastq=$(echo $fastq|awk -F/ '{print $NF}') #just the file name without the full path
echo $fastq
porechop -t 4 --extra_end_trim 0 -i $INDIR/$fastq -o $OUTDIR/porechop_${fastq}
done

echo 'Job completed'

}

function Chopper_QT { 

work_dir=$1
INDIR=$HOME/scratch/$work_dir/results/amp5-porechop
OUTDIR=$HOME/scratch/$work_dir/results/amp6-chopper

echo 'running chopper for quality trimming'

for fastq in $(ls $INDIR/*fastq)
do
fastq=$(echo $fastq|awk -F/ '{print $NF}') #just the file name without the full path
echo $fastq
chopper -q 10 -l 500 -i $INDIR/$fastq > $OUTDIR/${fastq/porechop/chopper} #in the word tutorial, prechopper and chopper sections are identical
done

echo 'Chopper Job completed'
}

function ampliconsorter {

work_dir=$1
INDIR=$HOME/scratch/$work_dir/results/amp6-chopper
OUTDIR=$HOME/scratch/$work_dir/results/amp7-ampliconsorter
AMPLICON_SORTER_PATH=$HOME/scratch/apps/amplicon_sorter


echo 'running ampliconsorter to create consensus'

for fastq in $(ls $INDIR/*fastq)
do
fastq=$(echo $fastq|awk -F/ '{print $NF}') #just the file name without the full path

echo $fastq
$HOME/projects/rbge/$USER/env/$env_name/bin/python3 $AMPLICON_SORTER_PATH/amplicon_sorter.py \ #you probably need to do the full path. for me the program is always looking at /bin/python3 where none of the newly downloaded packages specific to this env is installed
        -i $INDIR/$fastq \
        -o $OUTDIR/ampsorter.bc${fastq/chopper/}.def \
        -np $SLURM_CPUS_PER_TASK \
        -ar -maxr 570000

done


}



# Check command-line argument and call the function
case "$1" in
    make_work_dir)
        make_work_dir $2  # 
        ;;
    basecalling)
        basecalling $2 $3   #
        ;;
    demultiplex)
        demultiplex $2  # 
        ;;
    samtools_fastq)
        samtools_fastq $2    # 
        ;;
    NanoPlot_QC)
        NanoPlot_QC $2 $3 $4  # 
        ;;
    Porechop_trim)
        Porechop_trim $2 #
        ;;
    Chopper_QT)
        Chopper_QT $2   # 
        ;;
    ampliconsorter)
        ampliconsorter "$2"  # 
        ;;
    *)
        echo "Usage: $0 {making_work_dir|basecalling|demultiplex|samtools_fastq|NanoPlot_QC|Porechop_trim|Chopper_QT|ampliconsorter} [args]"
        exit 1
        ;;
esac