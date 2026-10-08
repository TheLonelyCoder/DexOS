format ELF

use32

public dex_init
public dex_print_string
public dex_wait_for_key

section '.text' executable

dex_init:
    mov edi,Functions
    mov al,0
    mov ah,0x0a
    int 50h
    ret


dex_print_string:
    push ebp
    mov ebp,esp

    mov esi,[ebp+8]
    call dword [PrintString_0]

    mov esp,ebp
    pop ebp
    ret

dex_wait_for_key:
    call dword [WaitForKeyPress]
    ret

align 4

include 'Dex.inc'
