#ensure PBS on path
export PATH=$PATH:/opt/pbs/bin
export PATH=$PATH:/tmp
LOCAL_TAR=/tmp/azcopy.tar.gz
wget -O ${LOCAL_TAR} https://aka.ms/downloadazcopy-v10-linux >/dev/null
tar -xzf ${LOCAL_TAR} --strip-components 1 --wildcards **/azcopy

#add mpi
module add mpi/hpcx

#download/install MemXCT-CPU
if [[ ! -d "$HOME/MemXCT" ]]; then
  git clone https://github.com/gadube/MemXCT-CPU.git $HOME/MemXCT
fi

cd $HOME/MemXCT
mv Makefile.azure Makefile
make clean
make
