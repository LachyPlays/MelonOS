;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Real-mode to protected-mode trampoline ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

[org 0x7c00]
[bits 16]


; Start of program
bootloader_start:
    mov bp, 0x0500
    mov sp, bp

    mov byte[boot_drive], dl

    lea bx, msg_hello_world
    call print_bios

    ; Load the next sector
    ; BX = Sector offset
    ; CX = Sector count
    ; DX = Address
    mov bx, 0x0002
    mov cx, 4
    mov dx, 0x7e00
    call load_bios

    ; Elevate to 32bit protected
    ; mode, and upper bootloader
    call elevate_bios

bootloader_end:
    jmp $ ; Loop forever

; Includes
%include "real_mode/print.asm"
%include "real_mode/load.asm"
%include "real_mode/gdt.asm"
%include "real_mode/elevate.asm"

; Variables
msg_hello_world: db `\r\nHello World, from the bios!\r\n`, 0
boot_drive: db 0x00

times 510 - ($ - $$) db 0x00 ; Zero out reserve bytes
                             ; also acts as a size limiter
; The *magic* number
dw 0xAA55

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 32-bit bootloader code ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; The extended bootsector, to be loaded
; from disk
bootsector_extended:
begin_protected:
    call clear_protected

    mov esi, protected_mode_msg
    call print_protected

    call detect_lm_protected
    call clear_protected
    mov esi, lm_supported_msg
    call print_protected

    call init_pt_protected

    call elevate_protected

    jmp $

%include "protected_mode/vga.asm"
%include "protected_mode/detect_lm.asm"
%include "protected_mode/init_pt.asm"
%include "protected_mode/gdt.asm"
%include "protected_mode/elevate.asm"

; Define necessary constants
vga_start:                  equ 0x000B8000
vga_extent:                 equ 80 * 25 * 2             ; VGA Memory is 80 chars wide by 25 chars tall (one char is 2 bytes)
style_wb:                   equ 0x0F

; Define messages
protected_mode_msg:                 db `[INFO] Entered 32-bit protected mode\r\n`, 0
lm_supported_msg:                   db `[INFO] Long mode supported`, 0

; Pad out the rest of the sector
times 512 - ($- bootsector_extended) db 0x00
begin_long_mode:

[bits 64]
    mov rdi, style_black
    call clear_long

    mov rdi, style_black
    mov rsi, long_mode_msg
    call print_long

    call kernel_start

    mov rdi, style_black
    mov rsi, returned_from_kernel_msg
    call print_long

    jmp $

%include "long_mode/print.asm"

long_mode_msg: db `[INFO] Entered 64-bit long mode`, 0
returned_from_kernel_msg: db `[WARN] Returned from kernel`, 0

kernel_start:                    equ 0x8200
style_black:                     equ 0x0F

times 512 - ($ - begin_long_mode) db 0x00