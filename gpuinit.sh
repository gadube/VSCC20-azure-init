#!/bin/bash
#ensure PBS on path
export PATH=$PATH:/opt/pbs/bin

#add mpi
module add mpi/hpcx


#download/install MemXCT-CPU
if [[ ! -d "$HOME/MemXCT" ]]; then
  git clone https://github.com/gadube/MemXCT-GPU.git $HOME/MemXCT
fi
cd $HOME/MemXCT
mv Makefile.azure.gpu Makefile
make clean
make
