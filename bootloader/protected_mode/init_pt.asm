;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sets up LM page table ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

[bits 32]

; Sets up an identity mapped 2MB page table
; from 0x1000 to 0x4fff
init_pt_protected:
    pushad

    ; We will clear all the 
    ; PT memory to 0x00, and point
    ; CR3 to this memory
    mov edi, 0x1000
    mov cr3, edi
    xor eax, eax
    mov ecx, 4096 ; 4096 * 4 bytes = sizeof(PT)
    rep stosd     ; Zero out the entries

    ; Point EDI back to the PLM4 table
    mov edi, cr3

    mov dword[edi], 0x2003  ; Set PLM4T[0] to 0x2000 (PDPT) with flags 0x0003
    add edi, 0x1000         ; Point EDI to PDPT[0]
    mov dword[edi], 0x3003  ; Set PDPT[0] to 0x3000 (PDT) with flags 0x0003
    add edi, 0x1000         ; Point EDI to PDT[0]
    mov dword[edi], 0x4003  ; Set PDT[0] to 0x4000 (PT) with flags 0x0003

    ; Now we need to fill in the Page Table. It will
    ; identity mapped, so PT[0] = 0x00, PT[1] = 0x01 etc.
    add edi, 0x1000         ; Point EDI to 0x4000
    mov ebx, 0x00000003     ; EBX has address 0 with flags 0x003
    mov ecx, 512            ; Do 512 times, as there are 512 entries in the page table
.add_page_table_entry_protected:
    mov dword[edi], ebx     ; PT[x] = address[31:12] << 12 | flags & 0xFFF
    add ebx, 0x1000         ; address + 1
    add edi, 8              ; x += sizeof(PTE)

    loop .add_page_table_entry_protected

    ; Set up the CPU in preparation of paging,
    ; but don't enable it yet
    mov eax, cr4
    or eax, 1 << 5  ; Set the paging bit, which is bit 5
    mov cr4, eax

    ; The kernel identity table is now prepared
    popad 
    ret