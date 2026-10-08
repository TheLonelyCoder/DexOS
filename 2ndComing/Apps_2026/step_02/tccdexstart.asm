format ELF

use32

public _start

extrn main
extrn dex_init
extrn __bss_start
extrn __bss_end

section '.text' executable

_start:
    jmp dex_start
    db 'DEX6'

dex_start:
    mov ax,18h
    mov ds,ax
    mov es,ax

    ; Initialize .bss
    mov edi,__bss_start
    mov ecx,__bss_end
    sub ecx,edi

    ; xor eax,eax         ; Original: Initialize with 0x00
    mov eax,0A5h          ; TEST: Initialize with 0xA5

    cld
    rep stosb

    ; Initialize DexOS runtime
    call dex_init

    ; Run C program
    call main

    ret

    