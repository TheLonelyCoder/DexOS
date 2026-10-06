#!/usr/bin/env bash

set -e

fasm Hello.asm Hello-linux.dex

cmp Hello-linux.dex ../../../Apps_2012/Hello_c/Hello.dex

echo
echo "SUCCESS: Generated binary is byte-for-byte identical to the original." 