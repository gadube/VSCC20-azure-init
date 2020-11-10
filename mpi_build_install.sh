#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


GCC_VERSION=gcc-9.2.0
INSTALL_PREFIX=/persist/tools

# load extra libraries
HPCX_FOLDER=hpcx-v2.7.0-gcc-MLNX_OFED_LINUX-5.1-0.6.6.0-redhat7.7-x86_64
HPCX_PATH=${INSTALL_PREFIX}/${HPCX_FOLDER}
HCOLL_PATH=${HPCX_PATH}/hcoll
UCX_PATH=${HPCX_PATH}/ucx

#define versions (make sure to change the URL version too)
OMPI_VERSION="3.1.0"
OMPI_DOWNLOAD_URL=https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-${OMPI_VERSION}.tar.gz
INSTALL_PATH=${INSTALL_PREFIX}/openmpi-${OMPI_VERSION}

# Load gcc
export PATH=/opt/${GCC_VERSION}/bin:$PATH
export LD_LIBRARY_PATH=/opt/${GCC_VERSION}/lib64:$LD_LIBRARY_PATH
set CC=/opt/${GCC_VERSION}/bin/gcc
set GCC=/opt/${GCC_VERSION}/bin/gcc

# get the source tar if it does not already exist
if [[ ! -f openmpi-${OMPI_VERSION}.tar.gz ]]; then
  wget -O openmpi-${OMPI_VERSION}.tar.gz ${OMPI_DOWNLOAD_URL}
fi


echo "moving to /mnt/resource (compile is faster not over nfs)"
sudo chown ccuser /mnt/resource
cp openmpi-${OMPI_VERSION}.tar.gz /mnt/resource/
cd /mnt/resource

echo "untaring..."
tar -xf openmpi-${OMPI_VERSION}.tar.gz
cd openmpi-${OMPI_VERSION}
sudo ./configure --prefix=${INSTALL_PATH} --with-ucx=${UCX_PATH} --with-hcoll=${HCOLL_PATH} --enable-mpirun-prefix-by-default --with-tm=/opt/pbs --with-platform=contrib/platform/mellanox/optimized && sudo make -j$(nproc) && sudo make install && echo "installed to ${INSTALL_PATH}"
#sudo ./configure --prefix=${INSTALL_PATH} --enable-mpirun-prefix-by-default --with-tm=/opt/pbs && sudo make -j$(nproc) && sudo make install && echo "installed to ${INSTALL_PATH}"
# create modulefile
mkdir -p ${INSTALL_PREFIX}/modulefiles/mpi/
cat << EOF >> ${INSTALL_PREFIX}/modulefiles/mpi/openmpi-${OMPI_VERSION}
#%Module 1.0
#
#  OpenMPI ${OMPI_VERSION}
#
conflict        mpi
module load ${GCC_VERSION}
prepend-path    PATH            ${INSTALL_PATH}/bin
prepend-path    LD_LIBRARY_PATH ${INSTALL_PATH}/lib
prepend-path    MANPATH         ${INSTALL_PATH}/share/man
setenv          MPI_BIN         ${INSTALL_PATH}/bin
setenv          MPI_INCLUDE     ${INSTALL_PATH}/include
setenv          MPI_LIB         ${INSTALL_PATH}/lib
setenv          MPI_MAN         ${INSTALL_PATH}/share/man
setenv          MPI_HOME        ${INSTALL_PATH}
EOF

echo "Modulefile created for mpi/openmpi-${OMPI_VERSION}"
