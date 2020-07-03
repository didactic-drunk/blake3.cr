#!/bin/sh

set -e

git submodule update --init --recursive

cd BLAKE3/c
make -f ../../build/Makefile
