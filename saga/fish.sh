#!/bin/bash
#
# Build fish on saga.sigma2.no.

# -- Prepare ------------------------------------------------------------------

# variables (this is the last C++ version not requiring rust)
version="3.6.1"
arch="saga-gnu"

# paths
source="$HOME/.local/src/fish"
prefix="$HOME/.local/opt/fish/$version-$arch"

# clone repo if missing
[ -d "$source" ] || git clone https://github.com/fish-shell/fish-shell.git $source
cd $source

# checkout version
git checkout $version

# -- Install -----------------------------------------------------------------

# cmake (this module does not load any gcc libs)
module purge &> /dev/null
module add CMake/3.12.1

# compilers and linker path (need gcc >= 11)
export CC="/cluster/software/GCCcore/11.3.0/bin/gcc"
export CXX="/cluster/software/GCCcore/11.3.0/bin/g++"

# configure and make install
CURSES_ROOT="/cluster/software/ncurses/6.3-GCCcore-11.3.0/"
make clean
mkdir -p build; cd build
cmake .. \
    -DCMAKE_VERBOSE_MAKEFILE=True \
    -DCMAKE_INSTALL_PREFIX=$HOME/.local/opt/fish/$version-$arch \
    -DCURSES_LIBRARY=$CURSES_ROOT/lib/libncurses.so \
    -DCURSES_INCLUDE_PATH=$CURSES_ROOT/include
make install
