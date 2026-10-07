
format ELF

use32

public _start
public dex_print_string

extrn main

section '.text' executable

_start:
    jmp dex_start
    db 'DEX6'

dex_start:
    mov ax,18h
    mov ds,ax
    mov es,ax

    mov edi,Functions
    mov al,0
    mov ah,0x0a
    int 50h

    call main

    ret


dex_print_string:
    push ebp
    mov ebp,esp

    mov esi,[ebp+8]
    call dword [PrintString_0]

    mov esp,ebp
    pop ebp
    ret


align 4

include 'Dex.inc'