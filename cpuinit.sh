#ensure PBS on path
export PATH=$PATH:/opt/pbs/bin

#add mpi
module add mpi/hpcx

#download/install MemXCT-CPU
git clone https://github.com/gadube/MemXCT-CPU.git $HOME/MemXCT
cd MemXCT
make clean
make
