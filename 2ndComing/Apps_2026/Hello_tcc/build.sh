#!/usr/bin/env bash

set -e

SOURCE_IMAGE="$HOME/VMs/images/dexos/DexOS/Floppy image_2012/DexOSv6.ima"
TEST_IMAGE="/tmp/DexOS-tcc-test.ima"

echo "=== 1. Startup assemblieren ==="

fasm startup.asm startup.o


echo
echo "=== 2. C compilieren ==="

tcc \
    -m32 \
    -nostdlib \
    -static \
    -c hello.c \
    -o hello.o


echo
echo "=== 3. Linken ==="

tcc \
    -m32 \
    -nostdlib \
    -static \
    -Wl,-Ttext=01A00000 \
    -o hello.elf \
    startup.o \
    hello.o


echo
echo "=== 4. DEX erzeugen ==="

objcopy \
    -O binary \
    --only-section=.text \
    hello.elf \
    hello_tcc.dex


echo
echo "=== 5. Test-Image erzeugen ==="

cp "$SOURCE_IMAGE" "$TEST_IMAGE"


echo
echo "=== 6. DEX ins Image kopieren ==="

mcopy \
    -i "$TEST_IMAGE" \
    hello_tcc.dex \
    ::HELLOTCC.DEX


echo
echo "=== Ergebnis ==="

ls -l hello_tcc.dex
mdir -i "$TEST_IMAGE" ::HELLOTCC.DEX

echo
echo "Test-Image: $TEST_IMAGE"