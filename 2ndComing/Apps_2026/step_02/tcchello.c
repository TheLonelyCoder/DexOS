#include "dexos.h"

int main(void)
{
    dex_print_string("Hellorld!\r\n");
    dex_print_string("Greetings to Usagi Electric.\r\n\r\n");

    dex_print_string("Press any key to continu ...\r\n");
    dex_wait_for_key();

    dex_print_string("Now with separated runtime!\r\n");
    dex_wait_for_key();

    return 42;
}