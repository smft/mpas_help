#!/bin/bash

#
# Sources for all libraries used in this script can be found at
# http://www2.mmm.ucar.edu/people/duda/files/mpas/sources/ 
#

# Where to find sources for libraries
export LIBSRC=/sysdisk1/duda/io_library_sources

# Where to install libraries
export LIBBASE=/sysdisk1/duda/mpas_io

# Compilers
export SERIAL_FC=gfortran
export SERIAL_F77=gfortran
export SERIAL_CC=gcc
export SERIAL_CXX=g++
export MPI_FC=mpif90
export MPI_F77=mpif77
export MPI_CC=mpicc
export MPI_CXX=mpicxx


########################################
# MPICH
########################################
tar xzvf ${LIBSRC}/mpich-3.1.3.tar.gz
cd mpich-3.1.3
export CC=$SERIAL_CC
export CXX=$SERIAL_CXX
export F77=$SERIAL_F77
export FC=$SERIAL_FC
./configure --prefix=${LIBBASE}
make
make check
make install
cd ..

########################################
# cmake
########################################
tar xzvf ${LIBSRC}/cmake-3.4.0-rc3.tar.gz
cd cmake-3.4.0-rc3
./bootstrap --prefix=${LIBBASE}
gmake
gmake install
export PATH=${LIBBASE}/bin:$PATH
cd ..

########################################
# zlib
########################################
tar xzvf ${LIBSRC}/zlib-1.2.8.tar.gz
cd zlib-1.2.8
./configure --prefix=${LIBBASE}
make
make install
cd ..

########################################
# HDF5
########################################
tar xjvf ${LIBSRC}/hdf5-1.8.14.tar.bz2
cd hdf5-1.8.14
export FC=$MPI_FC
export CC=$MPI_CC
export CXX=$MPI_CXX
./configure --prefix=${LIBBASE} --enable-parallel --with-zlib=${LIBBASE} --enable-fortran
make
make check
make install
cd ..

########################################
# Parallel-netCDF
########################################
tar xjvf ${LIBSRC}/parallel-netcdf-1.7.0.tar.bz2
cd parallel-netcdf-1.7.0
export CC=$SERIAL_CC
export CXX=$SERIAL_CXX
export F77=$SERIAL_F77
export FC=$SERIAL_FC
export MPICC=$MPI_CC
export MPICXX=$MPI_CXX
export MPIF77=$MPI_F77
export MPIF90=$MPI_FC
./configure --prefix=${LIBBASE}
make
make testing
make install
export PNETCDF=${LIBBASE}
cd ..

########################################
# netCDF (C library)
########################################
tar xzvf ${LIBSRC}/netcdf-4.4.0.tar.gz
cd netcdf-4.4.0
export CPPFLAGS="-I${LIBBASE}/include"
export LDFLAGS="-L${LIBBASE}/lib"
export LIBS="-lhdf5_hl -lhdf5 -lz -ldl"
export LD_LIBRARY_PATH=${LIBBASE}/lib:$LD_LIBRARY_PATH
export CC=$MPI_CC
./configure --prefix=${LIBBASE} --disable-dap --enable-netcdf4 --enable-pnetcdf --enable-parallel-tests --disable-shared
make
make check
make install
export NETCDF=${LIBBASE}
cd ..

########################################
# netCDF (Fortran interface library)
########################################
tar xzvf ${LIBSRC}/netcdf-fortran-4.4.3.tar.gz
cd netcdf-fortran-4.4.3
export FC=$MPI_FC
export F77=$MPI_F77
export LIBS="-lnetcdf ${LIBS}"
./configure --prefix=${LIBBASE} --enable-parallel-tests --disable-shared
make
make check
make install
cd ..

########################################
# PIO
########################################
tar xzvf ${LIBSRC}/pio1_9_23.tar.gz
cd ParallelIO-pio1_9_23
cd pio
export PIOSRC=`pwd`
git clone https://github.com/PARALLELIO/genf90.git bin
git clone https://github.com/CESM-Development/CMake_Fortran_utils.git cmake
cd ../..
pushd $LIBBASE
mkdir pio-1.9.23
cd pio-1.9.23
cmake -DNETCDF_C_DIR=$NETCDF -DNETCDF_Fortran_DIR=$NETCDF -DPNETCDF_DIR=$PNETCDF -DCMAKE_VERBOSE_MAKEFILE=1 $PIOSRC
make
export PIO=`pwd`
popd

########################################
# Other environment vars needed by MPAS
########################################
export MPAS_EXTERNAL_LIBS="-L${LIBBASE}/lib -lhdf5_hl -lhdf5 -ldl -lz"
export MPAS_EXTERNAL_INCLUDES="-I${LIBBASE}/include"
