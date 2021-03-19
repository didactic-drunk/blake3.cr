#!/bin/sh

set -e

#git submodule update --init --recursive

cd blake3c
make -f ../build/Makefile
