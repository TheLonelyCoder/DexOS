#include "dexos.h"

char second_greeting[] = "Hellorld from .data!\r\n";
char bss_buffer[80];

void PressAnyKeyToContinue()
{
    dex_print_string("Press any key to continue ...\r\n");
    dex_wait_for_key();
}

int main(void)
{
    dex_print_string("Hellorld!\r\n");
    dex_print_string("Greetings to Usagi Electric.\r\n");

    PressAnyKeyToContinue();

    dex_print_string("Now with separated runtime!\r\n");
    dex_wait_for_key();

    dex_print_string(second_greeting);
    PressAnyKeyToContinue();

    int bss_is_zero = 1;

    for (int i = 0; i < 80; i++)
    {
        if (bss_buffer[i] != 0x00)
        {
            bss_is_zero = 0;
            break;
        }
    }

    if (bss_is_zero == 1)
    {
        dex_print_string("BSS initialization: OK\r\n");
    }
    else
    {
        dex_print_string("BSS initialization: FAILED\r\n");
    }
    PressAnyKeyToContinue();

    bss_buffer[0] = 'A';
    bss_buffer[79] = 'Z';

    if ((bss_buffer[0] == 'A') && (bss_buffer[79] == 'Z'))
    {
        dex_print_string("BSS read/write: OK\r\n");
    }
    else
    {
        dex_print_string("BSS read/write: FAILED\r\n");
    }

    PressAnyKeyToContinue();
    
    dex_print_string("Now with 'ld' as linker\r\n");

    dex_print_string("Press any key to exit ...\r\n");
    dex_wait_for_key();

    return 42;
}
