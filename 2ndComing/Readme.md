# DexOS: The Second Coming

This directory contains experiments for building and running the
original DexOS sources on modern systems.

The original DexOS source tree is intentionally left untouched.

## Experiment 001 - Rebuilding Hello.dex

The original DexOS v6 repository contains:

    Apps_2012/Hello_c/Hello.asm
    Apps_2012/Hello_c/Hello.dex

The first experiment tests whether a current Linux version of FASM
can reproduce the original binary.

Run:

    cd Apps_2026/Hello_c
    ./build.sh

The script assembles `Hello.asm` and compares the resulting binary
with the original `Hello.dex` using `cmp`.

A successful build ends with:

    SUCCESS: Generated binary is byte-for-byte identical to the original.

Tested successfully on Linux Mint in October 2026.  