#include <stdint.h>

enum colour_code_t{
    BLACK_ON_WHITE = 0x0F
};

// Clears the screen to black
void clear_screen();

// Puts a char on the screen
void put_char(char c);

// Puts a string on the screen
void put_str(const char* str);