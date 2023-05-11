#ifndef _CPU_PORTS
#define _CPU_PORTS

#include <stdint.h>

// Read an 8-bit byte from a port
uint8_t port_byte_in(uint16_t port);

// Write an 8-bit byte to a port
void byte_out(uint16_t port, uint8_t data);

#endif