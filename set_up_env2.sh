#!/bin/bash
#first use srun --partition=short --cpus-per-task=8 --mem=30G --pty bash to get enough memory


env_name=amp_test
USER=zedchen #where the env will be saved to by default: $HOME/projects/rbge/$USER/env/$env_name/
WORKDIR=zed_chen/amp_test # subdirectory on scratch where the project will be carried out: $HOME/scratch/$work_dir/


#Install samtools, NanoPlot, porechop, chopper
conda install -c bioconda samtools -y
conda install -c bioconda nanoplot -y
conda install -c bioconda porechop -y
mamba install chopper
mamba update chopper 
#Install dependencies of ampliconsorter 
#python3 -m pip install edlib
#python3 -m pip install biopython
#python3 -m pip install matplotlib
#/bin/python3: No module named pip
#Install dependencies of ampliconsorter 
#
conda install pip -y #install pip
pip=$HOME/projects/rbge/$USER/env/$env_name/bin/pip #install with pip
pip install edlib
pip install biopython
pip install matplotlib

#conda install edlib -y
#conda install biopython -y 
#conda install matplotlib -y
#

#Create working directory under scratch
function make_work_dir {
#in your scratch directory, make your project directory
#this function should be run one and only once
work_dir=$1

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
}

#MAKE DIRECTORY
make_work_dir $WORKDIR #only run once
