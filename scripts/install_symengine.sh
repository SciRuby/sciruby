#!/bin/sh

# Clone SymEngine and checkout to the commit symengine.rb was tested with
export LAST_DIR=`pwd`
git clone https://github.com/symengine/symengine.git symengine-cpp
cd symengine-cpp
wget https://raw.githubusercontent.com/symengine/symengine.rb/master/symengine_version.txt
git checkout `cat symengine_version.txt`

# Build and install SymEngine
mkdir build && cd build
export CXX=g++-4.7
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=no ..
sudo make -j8 install
cd $LAST_DIR
rm -rf symengine-cpp


