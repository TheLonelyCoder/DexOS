#!/usr/bin/env bash

set -e

SOURCE_IMAGE="$HOME/VMs/images/dexos/DexOS/Floppy image_2012/DexOSv6.ima"
TEST_IMAGE="/tmp/DexOS-tcc-test.ima"

echo "=== 1. DexOS-Startup assemblieren ==="

fasm tccdexstart.asm tccdexstart.o
fasm dexruntime.asm dexruntime.o

echo
echo "=== 2. C compilieren ==="

tcc \
    -m32 \
    -nostdlib \
    -static \
    -c tcchello.c \
    -o tcchello.o


echo
echo "=== 3. Linken ==="

#tcc \
#    -m32 \
#    -nostdlib \
#    -static \
#    -Wl,-Ttext=01A00000 \
#    -o hellotcc.elf \
#    tccdexstart.o \
#    dexruntime.o \
#    tcchello.o


ld -m elf_i386 -T dexos.ld \
    -o hellotcc.elf \
    tccdexstart.o \
    dexruntime.o \
    tcchello.o

echo
echo "=== 4. DEX erzeugen ==="

# --only-section=.text \
objcopy \
    -O binary \
    hellotcc.elf \
    hellotcc.dex


echo
echo "=== 5. Test-Image erzeugen ==="

cp "$SOURCE_IMAGE" "$TEST_IMAGE"


echo
echo "=== 6. DEX ins Image kopieren ==="

mcopy \
    -i "$TEST_IMAGE" \
    hellotcc.dex \
    ::HELLOTCC.DEX


echo
echo "=== Ergebnis ==="

ls -l hellotcc.dex
mdir -i "$TEST_IMAGE" ::HELLOTCC.DEX

echo
echo "Test-Image: $TEST_IMAGE"
