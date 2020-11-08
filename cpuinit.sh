#ensure PBS on path
export PATH=$PATH:/opt/pbs/bin

#add mpi
module add mpi/hpcx

#download/install MemXCT-CPU
if [[ ! -d "$HOME/MemXCT" ]]; then
  git clone https://github.com/gadube/MemXCT-CPU.git $HOME/MemXCT
fi

cd $HOME/MemXCT
make clean
make
