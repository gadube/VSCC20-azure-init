#!/bin/bash

export PATH=$PATH:/opt/pbs/bin
export PATH=$PATH:/tmp
LOCAL_TAR=/tmp/azcopy.tar.gz
wget -O ${LOCAL_TAR} https://aka.ms/downloadazcopy-v10-linux >/dev/null
tar -xzf ${LOCAL_TAR} --strip-components 1 --wildcards **/azcopy
mv azcopy /tmp/azcopy

#install cuda
if ! [-x "$(command -v nvcc)" ]; then
  sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  sudo yum install dkms -y
  CUDA_REPO_PKG=cuda-repo-rhel7-10.0.130-1.x86_64.rpm
  wget http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/${CUDA_REPO_PKG} -O /tmp/${CUDA_REPO_PKG}
  sudo rpm -ivh /tmp/${CUDA_REPO_PKG}
  rm -f /tmp/${CUDA_REPO_PKG}
  sudo yum install cuda -y
  export PATH=$PATH:/usr/local/cuda/bin
fi
export CUDA_INSTALL_DIR=/usr/local/cuda

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
azcopy copy 'https://scc20input.blob.core.windows.net/memxct' '.' --recursive
tar -xvf memxct/MEMXCT.tar
mv CDS* $HOME/MemXCT/MemXCT_datasets/
rm -rf memxct

make
