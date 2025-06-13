#!/bin/bash
#first use srun --partition=short --cpus-per-task=8 --mem=30G --pty bash to get enough memory

#install programs manually/conda

env_name=$1 
#for instance, minion
mkdir $HOME/scratch/apps
# Manually Download programs in scratch/apps
cd $HOME/scratch/apps
#Download dorado package
git clone https://github.com/avierstr/amplicon_sorter.git
wget https://cdn.oxfordnanoportal.com/software/analysis/dorado-0.4.1-linux-x64.tar.gz
#Extract tar.gz
tar -xzvf dorado-0.4.1-linux-x64.tar.gz
cd dorado-0.4.1-linux-x64
mkdir model
cd ./model
#Download model
../bin/dorado download --model dna_r10.4.1_e8.2_400bps_hac@v4.2.0

#make environemnt (everything else can be found from conda)
#conda config --show channels
conda install -c conda-forge mamba
conda create -n $env_name #make an env 
#check with conda env list
#it's saved to home directory on projects/USER/env
conda activate $env_name #Activate environment

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
#just use conda install
conda install edlib -y
conda install biopython -y 
conda install matplotlib -y
#
