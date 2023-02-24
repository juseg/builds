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
version="2.0.5"
arch="saga-gnu"

# checkout pism version
cd "$HOME/.local/src/pism"
git checkout v$version

# change to build dir
mkdir -p build-$version-$arch
cd build-$version-$arch

# -- Configure ---------------------------------------------------------------

# this is the latest petsc on 20.10.2022
export PETSC_DIR=/cluster/software/PETSc/3.15.1-foss-2021a

# it uses cgg-10.3.0 and gompi-2021 (pnetcdf is only available for iimpi)
export CC=/cluster/software/OpenMPI/4.1.1-GCC-10.3.0/bin/mpicc
export CXX=/cluster/software/OpenMPI/4.1.1-GCC-10.3.0/bin/mpicxx
export FFTW_ROOT=/cluster/software/FFTW/3.3.9-gompi-2021a
export GSL_ROOT=/cluster/software/GSL/2.7-GCC-10.3.0
export HDF5_ROOT=/cluster/software/HDF5/1.10.7-gompi-2021a
export NETCDF_ROOT=/cluster/software/netCDF/4.8.0-gompi-2021a
export UDUNITS2_ROOT=/cluster/software/UDUNITS/2.2.28-GCCcore-10.3.0
export PROJ_ROOT=/cluster/software/PROJ/8.0.1-GCCcore-10.3.0

# cmake needs this to find ncgen
export PATH=/cluster/software/netCDF/4.8.0-gompi-2021a/bin/:$PATH

# and this to find the right ld
export PATH=/cluster/software/binutils/2.36.1-GCCcore-10.3.0/bin/:$PATH

# cmake (this module does not load any gcc libs)
module add CMake/3.12.1

# configure (need salloc session to run tests)
cmake .. \
    -DCMAKE_INSTALL_PREFIX="$HOME/.local/opt/pism/$version-$arch" \
    -DPETSC_EXECUTABLE_RUNS=YES \
    -DPism_USE_PARALLEL_NETCDF4=YES \
    -DPism_USE_PNETCDF=NO \
    -DPism_USE_PROJ=YES

# -- Install -----------------------------------------------------------------

# netcdf is needed for pism_config.nc
module add netCDF/4.8.0-gompi-2021a

# install
make -j install
