bits 16
org 0x500 ; We need to get way out of the way in case we are chainloading

start:
    cli
    cld
    mov dl, [boot_drive]
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x7c00 ; The stack grows down, this is fine
    mov esi, 0x7c00
    mov edi, 0x500
    mov ecx, 256
    rep movsw
    jmp 0x0:real_start
real_start:
    sti
    mov ax, 0x2401 ; Enable A20 Gate
    int 0x15

    mov ah, 0x41
    mov bx, 0x55AA
    int 0x13
    jc .try_CHS
    cmp bx, 0xAA55
    jne .try_CHS
    mov si, DAP
    mov ah, 0x42
    int 0x13
    jc .try_CHS
    push dx
    jmp 0x0:0x5000

.try_CHS:
    clc
    xor ebx, ebx
    mov bx, 0x500
    mov es, bx
    xor bx, bx
    mov ah, 0x2
    mov al, 7
    mov ch, 0x0
    mov cl, 0x2
    mov dh, 0x0
    int 0x13
    jc .error
    push dx
    jmp 0x0:0x5000
.error:
    cli
    hlt

DAP:
    db 0x10, 0
    dw 3
    dd 0x5000
    dq 1

boot_drive: db 0
times 510 - ($ - $$) db 0
dw 0xAA55