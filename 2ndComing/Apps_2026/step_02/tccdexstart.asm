format ELF

use32

public _start
extrn main
extrn dex_init

section '.text' executable

_start:
    jmp dex_start
    db 'DEX6'

dex_start:
    mov ax,18h
    mov ds,ax
    mov es,ax

    call dex_init
    call main

    ret
    