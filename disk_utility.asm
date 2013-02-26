[BITS 16]
[org 0x7E00] ;starting point in memory to which program should be loaded

start:
                    ;attempt to start video mode
    mov ah,0x00
    mov al,0x13
    int 10h

    push di
    push ds
    mov bx, [P1]
    add bx, 0x04
    mov ax, bx
    mov di,bx
    mov bx,0x7C0
    mov ds,bx
.checkMBR:
    mov al, [DS:DI]
    cmp al, 0
    jg .read  
    jmp .skipRead
.read
    call print_char 
.skipRead
    add di,16
    cmp di,0x01F3
    jg .outOfLoop
    jmp .checkMBR
.outOfLoop
    retf

read_partition:
    retn

print_string:           ; Expects null terminated message in si    
    mov al,[si]
    or al,al            ;If character is 0x00, end
    jz  .end
    inc si
    call update_cursor
    call print_char
    jmp print_string
.end:
    retn

update_cursor:
    mov ah,0x02 ;set mode
    mov dl,cl   ;set position based on counter
    int 10h
    inc cl      ;increase counter
    retn

print_char:
    mov ah,0x0E         ; Specifies that we want to write a character to the screen
    mov bl,0x06         ; Specifies output text color.  Not required, but useful to know (Works only in video mode)
    mov bh,0x00         ; Page number.  Leave this alone.
    int 0x10            ; Signal video interrupt to BIOS
    retn

load_sector:                ;later rewrite to accept custom disc/memory locations
    mov ah,0x02 ;read  
    mov al,0x01 ;num of sectors
    ;CX =       ---CH--- ---CL---
    ;cylinder : 76543210 98
    ;sector   :            543210
    mov ch,0x00 
    mov cl,0x02 
    mov dh,0x00 ;head
    mov dl,0x80 ;0x80-primary disk 0x81-secondary disk, 0x00-1st floppy...
    mov bx,[LOC]    ;ES cant be loaded directly...
    shr bx,4        ;shift by 4 bits makes correction from complete adress to segment address
    mov es,bx
    mov bx,0x00 ;buffer offset 0
    int 13h
    retn

;data
    MSG db 'Well...this is really embarrassing',0x0A,0
    PAR db 'Partition empty',0
    LOC dw 0xFF
    P1 dw 0x01BE
    P2 dw 0x01CE
    P3 dw 0x01DE
    P4 dw 0x01EE

TIMES 512 - ($ - $$) db 0