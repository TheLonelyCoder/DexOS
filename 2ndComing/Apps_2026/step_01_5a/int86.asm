.8086

_TEXT SEGMENT BYTE PUBLIC USE16 'CODE'

PUBLIC int86_

int86_ PROC NEAR

    ; Watcom __watcall:
    ; AX = interrupt number (hier 10h)
    ; DX = &inregs
    ; BX = &outregs
    ;
    ; Für unseren Test sind inregs und outregs identisch.

    push si
    push di

    mov si,dx
    mov di,bx

    mov ax,[si]
    mov bx,[si+2]

    int 10h

    mov [di],ax
    mov [di+2],bx

    pop di
    pop si
    ret

int86_ ENDP

_TEXT ENDS

END
