;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Protected mode switching code ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

[bits 16]

; This raises the CPU to protected mode
elevate_bios:
    ; Disable interrupts, as switching to
    ; 32-bit mode can cause spurious interrupts
    cli

    ; Tell the CPU where the GDT is
    lgdt [gdt_32_descriptor]

    ; Enable 32-bit mode by setting bit 0
    ; of the CR0 register
    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax

    ; Do a far jump to clear the pipeline
    jmp code_seg:init_pm

[bits 32]

; From this point, we are now in
; 32bit protected mode
init_pm:
    ; Set up all segment registers.
    ; Since we are in flat-mode, we need to 
    ; set all segments to point to our descriptors
    mov ax, data_seg
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Set up the stack pointer,
    ; since the switch likely messed it up
    mov ebp, 0x90000
    mov esp, ebp

    jmp begin_protected

