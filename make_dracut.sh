#!/bin/bash
# dracut 046
git submodule init
git submodule update
cd dracut
make clean
./configure --disable-documentation
make
# make install
cd ..
