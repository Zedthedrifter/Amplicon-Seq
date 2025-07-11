#!/bin/bash
#first use srun --partition=short --cpus-per-task=8 --mem=30G --pty bash to get enough memory


env_name=amp_test
USER=zedchen #where the env will be saved to by default: $HOME/projects/rbge/$USER/env/$env_name/
WORKDIR=zed_chen/amp_test # subdirectory on scratch where the project will be carried out: $HOME/scratch/$work_dir/

#install programs manually/conda

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

#you can also add these lines to .bashrc file to config them permanently
export PATH=$PATH:$HOME/scratch/apps/dorado-0.4.1-linux-x64/bin
export PATH=$PATH:$HOME/scratch/apps/dorado-0.4.1-linux-x64
export LD_LIBRARY_PATH=$HOME/scratch/apps/dorado-0.4.1-linux-x64/lib:$LD_LIBRARY_PATH
MODEL=$HOME/scratch/apps/dorado-0.4.1-linux-x64/model/dna_r10.4.1_e8.2_400bps_hac\@v4.2.0/

#make environemnt (everything else can be found from conda)
#conda config --show channels
conda install -c conda-forge mamba
conda create -n $env_name #make an env 
#check with conda env list
#it's saved to home directory on projects/USER/env
