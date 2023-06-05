#!/bin/bash
#
# Build Neovim on saga.sigma2.no.

# -- Prepare -----------------------------------------------------------------

# variables
version="0.9.1"
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
module add CMake/3.18.4

# compiler paths
export CC="/cluster/software/GCCcore/11.3.0/bin/gcc"
export CXX="/cluster/software/GCCcore/11.3.0/bin/g++"

# configure and make install
make distclean
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=$prefix install
