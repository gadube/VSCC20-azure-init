#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


GCC_VERSION=gcc-9.2.0
INSTALL_PREFIX=/persist

# load extra libraries
HPCX_FOLDER=hpcx-v2.7.0-gcc-MLNX_OFED_LINUX-5.1-0.6.6.0-redhat7.7-x86_64
HPCX_PATH=${INSTALL_PREFIX}/${HPCX_FOLDER}
HCOLL_PATH=${HPCX_PATH}/hcoll
UCX_PATH=${HPCX_PATH}/ucx

OMPI_VERSION="4.0.3"
OMPI_DOWNLOAD_URL=https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-${OMPI_VERSION}.tar.gz

# Load gcc
export PATH=/opt/${GCC_VERSION}/bin:$PATH
export LD_LIBRARY_PATH=/opt/${GCC_VERSION}/lib64:$LD_LIBRARY_PATH
set CC=/opt/${GCC_VERSION}/bin/gcc
set GCC=/opt/${GCC_VERSION}/bin/gcc


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
# sudo ./configure --prefix=${INSTALL_PREFIX}/openmpi-${OMPI_VERSION} --with-ucx=${UCX_PATH} --with-hcoll=${HCOLL_PATH} --enable-mpirun-prefix-by-default --with-tm=/opt/pbs --with-platform=contrib/platform/mellanox/optimized && sudo make -j$(nproc) && sudo make install
sudo ./configure --prefix=${INSTALL_PREFIX}/openmpi-${OMPI_VERSION} --enable-mpirun-prefix-by-default --with-tm=/opt/pbs && sudo make -j$(nproc) && sudo make install

echo "installed to ${INSTALL_PREFIX}/openmpi-${OMPI_VERSION}"
# create modulefile
cat << EOF >> /usr/share/Modules/modulefiles/mpi/openmpi-${OMPI_VERSION}
#%Module 1.0
#
#  OpenMPI ${OMPI_VERSION}
#
conflict        mpi
module load ${GCC_VERSION}
prepend-path    PATH            /opt/openmpi-${OMPI_VERSION}/bin
prepend-path    LD_LIBRARY_PATH /opt/openmpi-${OMPI_VERSION}/lib
prepend-path    MANPATH         /opt/openmpi-${OMPI_VERSION}/share/man
setenv          MPI_BIN         /opt/openmpi-${OMPI_VERSION}/bin
setenv          MPI_INCLUDE     /opt/openmpi-${OMPI_VERSION}/include
setenv          MPI_LIB         /opt/openmpi-${OMPI_VERSION}/lib
setenv          MPI_MAN         /opt/openmpi-${OMPI_VERSION}/share/man
setenv          MPI_HOME        /opt/openmpi-${OMPI_VERSION}
EOF

echo "Modulefile created for mpi/openmpi-${OMPI_VERSION}"
