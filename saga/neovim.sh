#!/bin/bash
#
# Build Neovim on saga.sigma2.no.

# -- Prepare -----------------------------------------------------------------

# variables
version="0.8.3"
arch="saga-gnu"

# paths
source="$HOME/.local/src/neovim"
prefix="$HOME/.local/opt/neovim/$version-$arch"

# clone repo if missing
[ -d "$source" ] || git clone https://github.com/neovim/neovim.git $source
cd $source

# checkout version
git checkout v$version

# -- Install -----------------------------------------------------------------

# cmake (this module does not load any gcc libs)
module purge &> /dev/null
module add CMake/3.12.1

# compilers, linker path, recent git (as of Neovim 0.8.3 some dependency builds
# override CFLAGS, hence we pass the -B flag directly to CC variable; building
# deps has been completely reworked in the development version though).
# module add CMake/3.20.1-GCCcore-10.3.0
# module add git/2.32.0-GCCcore-10.3.0-nodocs
export CC="/cluster/software/GCCcore/10.3.0/bin/gcc \
    -B/cluster/software/binutils/2.36.1-GCCcore-10.3.0/bin/"
export CXX=/cluster/software/GCCcore/10.3.0/bin/g++
export PATH="/cluster/software/git/2.32.0-GCCcore-10.3.0-nodocs/bin:$PATH"

# configure and make install
# make distclean
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=$prefix install
