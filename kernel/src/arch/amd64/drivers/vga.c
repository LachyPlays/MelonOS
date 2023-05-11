#include "arch/amd64/drivers/vga.h"

#ifndef __VGA_DRIVER
#define __VGA_DRIVER

#define VIDEO_MEMORY 0xB8000

#define VIDEO_WIDTH  80
#define VIDEO_HEIGHT 25
#define VIDEO_EXTENT 80 * 25

static uint8_t col = 0;
static uint8_t row = 0;

typedef struct __attribute__((packed)) {
    uint8_t ascii;
    uint8_t colour_code;
} vga_pixel_t;

void clear_screen() {
    volatile vga_pixel_t* vga_buffer = (volatile vga_pixel_t*)VIDEO_MEMORY;

    for(int i = 0; i < VIDEO_EXTENT; i++) {
        const vga_pixel_t pixel = {0x00, 0x00};
        vga_buffer[i] = pixel;
    }
}

void put_char(char c) {
    // Buffer write
    volatile vga_pixel_t* vga_buffer = (volatile vga_pixel_t*)VIDEO_MEMORY;
    const vga_pixel_t pixel = { c, BLACK_ON_WHITE };
    vga_buffer[VIDEO_WIDTH * row + col] = pixel;

    // Address adjust
    col += 1;
    if (col >= VIDEO_WIDTH) {
        row += 1;
        col = 0;
    }
}

void put_str(const char* str) {
    volatile vga_pixel_t* vga_buffer = (volatile vga_pixel_t*)VIDEO_MEMORY;

    unsigned int i = 0;
    while(i < INT32_MAX) {
        const vga_pixel_t pixel = {str[i++], BLACK_ON_WHITE};
        vga_buffer[VIDEO_WIDTH * row + col] = pixel;

        col += 1;
        if (col >= VIDEO_WIDTH) {
            row += 1;
            col = 0;
        }

        if (str[i] == 0) break;
    }
}

#endif

