#!/bin/bash
#
# saga/pism.sh - Build PISM on saga.sigma2.no.
#
# Build PISM using only system libs. Inform CMake through `FFTW_ROOT` etc
# rather than `module add` so that modules don't need to be loaded at runtime.
# However, two sub-dependencies still need to be loaded at runtime:
#
#     module add OpenBLAS/0.3.15-GCC-10.3.0    # needed by PETSc
#     module add LibTIFF/4.2.0-GCCcore-10.3.0  # needed by PROJ

# -- Prepare -----------------------------------------------------------------

# variables
version="2.0.6"
arch="saga-gnu"

# checkout pism version
cd "$HOME/.local/src/pism"
git checkout v$version

# change to build dir
mkdir -p build-$version-$arch
cd build-$version-$arch

# -- Configure ---------------------------------------------------------------

# this is the latest petsc on 05.06.2023
export PETSC_DIR=/cluster/software/PETSc/3.17.4-foss-2022a

# it uses gcc-11.3.0 and gompi-2022a
export CC=/cluster/software/OpenMPI/4.1.4-GCC-11.3.0/bin/mpicc
export CXX=/cluster/software/OpenMPI/4.1.4-GCC-11.3.0/bin/mpicxx
export FFTW_ROOT=/cluster/software/FFTW.MPI/3.3.10-gompi-2022a
export GSL_ROOT=/cluster/software/GSL/2.7-GCC-11.3.0
export HDF5_ROOT=/cluster/software/HDF5/1.12.2-gompi-2022a
export NETCDF_ROOT=/cluster/software/netCDF/4.9.0-gompi-2022a
export UDUNITS2_ROOT=/cluster/software/UDUNITS/2.2.28-GCCcore-11.3.0
export PROJ_ROOT=/cluster/software/PROJ/9.0.0-GCCcore-11.3.0
export PNETCDF_ROOT=/cluster/software/PnetCDF/1.12.3-gompi-2022a

# cmake needs this to find ncgen
export PATH=/cluster/software/netCDF/4.9.0-gompi-2022a/bin/:$PATH

# and this to find the right ld
export PATH=/cluster/software/binutils/2.38-GCCcore-11.3.0/bin/:$PATH

# cmake (this module does not load any gcc libs)
module add CMake/3.18.4

# configure (need salloc session to run tests)
cmake .. \
    -DCMAKE_INSTALL_PREFIX="$HOME/.local/opt/pism/$version-$arch" \
    -DPETSC_EXECUTABLE_RUNS=YES \
    -DPism_USE_PARALLEL_NETCDF4=YES \
    -DPism_USE_PNETCDF=YES \
    -DPism_USE_PROJ=YES

# -- Install -----------------------------------------------------------------

# netcdf is needed for pism_config.nc
module add netCDF/4.9.0-gompi-2022a

# install
make clean
make -j install
