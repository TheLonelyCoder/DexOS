.8086

_TEXT SEGMENT WORD PUBLIC 'CODE'

ASSUME CS:_TEXT

PUBLIC _start
EXTRN main_:NEAR

_start PROC NEAR

    mov ah,0Eh
    mov al,'X'
    mov bh,00h
    mov bl,07h
    int 10h

    mov ax,DGROUP
    mov ds,ax
    mov es,ax

    mov ah,0Eh
    mov al,'Y'
    mov bh,00h
    mov bl,07h
    int 10h

    call main_

hang:
    jmp hang

_start ENDP

_TEXT ENDS


_DATA SEGMENT WORD PUBLIC 'DATA'
_DATA ENDS

CONST SEGMENT WORD PUBLIC 'DATA'
CONST ENDS

_BSS SEGMENT WORD PUBLIC 'BSS'
_BSS ENDS

DGROUP GROUP _DATA, CONST, _BSS


STACKSEG SEGMENT PARA STACK 'STACK'
    db 512 dup (?)
STACKSEG ENDS

END _start

