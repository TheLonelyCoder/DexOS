#!/usr/bin/env bash

set -e

IMAGE="DexOS-step-01-5a.ima"

echo "=== 1. Startup assemblieren ==="

wasm start.asm


echo
echo "=== 2. Eigene int86() assemblieren ==="

wasm int86.asm


echo
echo "=== 3. C compilieren ==="

wcc \
    -0 \
    -ms \
    -s \
    -zls \
    hellowat.c


echo
echo "=== 4. Ohne Watcom-Runtime linken ==="

wlink \
    format dos \
    option nodefaultlibs \
    option start=_start \
    name kernel32.exe \
    file start.o \
    file int86.o \
    file hellowat.o


echo
echo "=== 5. Ergebnis prüfen ==="

file kernel32.exe
ls -l kernel32.exe

echo
echo "=== 6. MZ Header ==="

xxd -l 64 kernel32.exe


echo
echo "=== 7. KERNEL32.EXE ins Test-Image kopieren ==="

mcopy \
    -o \
    -i "$IMAGE" \
    kernel32.exe \
    ::KERNEL32.EXE


echo
echo "=== 8. Inhalt des Test-Images ==="

mdir -i "$IMAGE" ::


echo
echo "SUCCESS: kernel32.exe built and copied to $IMAGE"
