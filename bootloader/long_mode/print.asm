;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Long mode print routines ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

[bits 64]

; Simple 32-bit protected print routine
; Style stored in rdi, message stored in rsi
print_long:
    push rax
    push rdx
    push rdi
    push rsi

    mov rdx, vga_start
    shl rdi, 8

    ; Do main loop
    print_long_loop:
        ; If char == \0, string is done
        cmp byte[rsi], 0
        je  print_long_done

        ; Handle strings that are too long
        cmp rdx, vga_start + vga_extent
        je print_long_done

        ; Move character to al, style to ah
        mov rax, rdi
        mov al, byte[rsi]

        ; Print character to vga memory location
        mov word[rdx], ax

        ; Increment counter registers
        add rsi, 1
        add rdx, 2

        ; Redo loop
        jmp print_long_loop

print_long_done:
    pop rsi
    pop rdi
    pop rdx
    pop rax

    ret

clear_long:
    push rdi
    push rax
    push rcx

    shl rdi, 8
    mov rax, rdi

    mov al, space_char

    mov rdi, vga_start
    mov rcx, vga_extent / 2

    rep stosw

    pop rcx
    pop rax
    pop rdi
    ret


space_char:                     equ ` `