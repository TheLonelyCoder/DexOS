#include <i86.h>

/*
void bios_putchar(char character)
{
    union REGS registers;

    registers.h.ah = 0x0E;
    registers.h.al = character;
    registers.h.bh = 0x00;
    registers.h.bl = 0x07;

    int86(0x10, &registers, &registers);
}
*/

void bios_putchar(char character)
{
    __asm
    {
        mov ah, 0Eh
        mov al, character
        mov bh, 00h
        mov bl, 07h
        int 10h
    }
}

int main(void)
{
    char *text;

    text = "Hellorld!\r\n";

    while (*text != '\0')
    {
        bios_putchar(*text);
        text++;
    }

    for (;;)
    {
    }

    return 0;
}
