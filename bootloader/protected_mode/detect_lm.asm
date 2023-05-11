;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Detect if long mode is present ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

[bits 32]

; Check if long mode is suppoted,
; error out and hang if it isnt
detect_lm_protected:
    pushad

    ; To check if long mode exists, we need
    ; to use the CPUID instruction, but the CPUID
    ; instruction isn't always supported, so we check
    ; if it is supported below, and hang if it isn't
    
    ; Since flags cannot be directly accessed,
    ; we read them from the stack instead
    pushfd
    pop eax

    ; Save to ecx for comparison
    mov ecx, eax

    ; To check for CPUID, we need to flip bit 21 of flags,
    ; which will revert back to the original value if CPUID does
    ; not exist
    xor eax, 1 << 21
    push eax
    popfd

    ; Read and compare flags
    pushfd
    pop eax

    ; Restore pre-comp flags
    push ecx
    popfd

    ; If ECX and EAX are equal, the bit was 
    ; reverted thus CPUID is not supported
    cmp eax, ecx
    je lm_not_supported_protected

    ; Now that we know CPUID exists, we need to find
    ; out if it supports extended functions, as this lets
    ; us check for long-mode support
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001 ; If the result of CPUID < 0x80000001, extended doesnt exist
    jb lm_not_supported_protected

    ; Now that we know we have CPUID, and that it supports extended
    ; functions, we can check if long mode is supported. If this passes,
    ; we know that this CPU has all the prerequisites for long mode
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29 ; If bit 29 is set, we support long mode
    jz lm_not_supported_protected ; If it's not set, error and hang

    ; We support long mode!
    ; Pop and return
    popad
    ret

lm_not_supported_protected:
    call clear_protected
    mov esi, lm_not_supported_msg
    call print_protected
    jmp $

lm_not_supported_msg: db `[FATAL] Long mode not supported, cannot continue`, 0


