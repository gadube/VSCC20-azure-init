#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


GCC_VERSION=gcc-9.2.0
INSTALL_PREFIX=/persist/tools

# load extra libraries
# HPCX_FOLDER=hpcx-v2.7.0-gcc-MLNX_OFED_LINUX-5.1-0.6.6.0-redhat7.7-x86_64
# HPCX_PATH=${INSTALL_PREFIX}/${HPCX_FOLDER}
# HCOLL_PATH=${HPCX_PATH}/hcoll
# UCX_PATH=${HPCX_PATH}/ucx

#define versions (make sure to change the URL version too)
CUDA_VERSION="10.2.89"
CUDA_DOWNLOAD_URL=http://developer.download.nvidia.com/compute/cuda/10.2/Prod/patches/1/cuda_10.2.1_linux.run
INSTALL_PATH=${INSTALL_PREFIX}/cuda-${CUDA_VERSION}

# Load gcc
export PATH=/opt/${GCC_VERSION}/bin:$PATH
export LD_LIBRARY_PATH=/opt/${GCC_VERSION}/lib64:$LD_LIBRARY_PATH
set CC=/opt/${GCC_VERSION}/bin/gcc
set GCC=/opt/${GCC_VERSION}/bin/gcc

# get the source tar if it does not already exist
if [[ ! -f cuda-${CUDA_VERSION}.tar.gz ]]; then
  wget -O cuda-${CUDA_VERSION}.tar.gz ${CUDA_DOWNLOAD_URL}
fi


echo "moving to /mnt/resource (compile is faster not over nfs)"
sudo chown ccuser /mnt/resource
cp cuda-${CUDA_VERSION}.tar.gz /mnt/resource/
cd /mnt/resource

echo "untaring..."
sudo ./cuda_10.2.89_440.33.01_linux.run --silent \
--toolkit --toolkitpath=${INSTALL_PATH}
--toolkit --toolkitpath=${INSTALL_PREFIX}/cuda-samples

# create modulefile
mkdir -p ${INSTALL_PREFIX}/modulefiles/cuda/
cat << EOF >> ${INSTALL_PREFIX}/modulefiles/cuda/cuda-${CUDA_VERSION}
#%Module 1.0
#
#  CUDA ${CUDA_VERSION}
#
conflict        mpi
module load ${GCC_VERSION}
prepend-path    PATH            ${INSTALL_PATH}/bin
prepend-path    LD_LIBRARY_PATH ${INSTALL_PATH}/lib
prepend-path    MANPATH         ${INSTALL_PATH}/share/man
setenv          CUDA_BIN        ${INSTALL_PATH}/bin
setenv          CUDA_INCLUDE    ${INSTALL_PATH}/include
setenv          CUDA_LIB        ${INSTALL_PATH}/lib
setenv          CUDA_MAN        ${INSTALL_PATH}/share/man
setenv          CUDA_HOME       ${INSTALL_PATH}
EOF

echo "Modulefile created for cuda/cuda-${CUDA_VERSION}"
