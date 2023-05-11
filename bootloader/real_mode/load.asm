;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Real mode sector loader ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

[bits 16]

load_bios:
    push ax
    push bx
    push cx
    push dx

    ; Save the number of sectors read,
    ; as this will be check again later
    push cx

    ; Choose ATA util interrupt
    mov ah, 0x02

    ; Number of sectors read needs to be in al,
    ; but the function takes it in CX  
    mov al, cl

    ; Sector to read from must be in cl,
    ; but the function takes it in bl
    mov cl, bl

    ; The destination address must be in bx,
    ; but the function takes it in dx
    mov bx, dx

    ; The cylinder and read to read from, respectively
    mov ch, 0x00 ; Cylinder
    mov dh, 0x00 ; Head

    ; Drive number goes in dl
    mov dl, byte[boot_drive]

    ; Perform BIOS disk read
    int 0x13

    ; Pop the sector count from earlier and
    ; compare it to the loaded count. If this doesnt match,
    ; error out since this would corrupt the bootloader
    pop bx
    cmp al, bl
    jne bios_sector_mismatch_error

    ; If there was an error with the disk read,
    ; the carry flag will be set. We will handle accordingly
    jc bios_disk_error

    ; If all was good, print, pop and ret
    mov bx, disk_success_msg
    call print_bios

    pop dx
    pop cx
    pop bx
    pop ax

    ret

bios_sector_mismatch_error:
    push bx

    mov bx, sector_error_msg
    call print_bios

    pop bx
    call print_hex_bios

    jmp $

bios_disk_error:
    ; Print out error code and hang,
    ; since without the disk load the
    ; bootloader cannot progress
    mov bx, disk_error_msg
    call print_bios

    ; Print out error code
    shr ax, 8
    mov bx, ax
    call print_hex_bios

    ; Hang
    jmp $

disk_error_msg: db `\r\[FATAL] Error loading disk with code : `, 0
sector_error_msg: db `\r\[FATAL] Sector count mismatch : `, 0
disk_success_msg: db `\r\[INFO] Bootloader loaded successfully\r\n`, 0
