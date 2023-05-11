#include "arch/amd64/drivers/vga.h"

int main(){
    clear_screen();
    put_str("Hello, World!");

    return 0;
}