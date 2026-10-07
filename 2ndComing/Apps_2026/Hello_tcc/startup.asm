format ELF

use32

public _start
extrn main

section '.text' executable

_start:
    jmp dex_start
    db 'DEX6'

dex_start:
    mov ax,18h
    mov ds,ax
    mov es,ax

    call main
    ret

.stop:
    jmp .stop

