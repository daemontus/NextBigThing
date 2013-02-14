[BITS 16]
[org 0x7C00]

start:
    
;attempt to start video mode
    mov ah,0x00
    mov al,0x13
    int 10h

;"Boot...wait for it...loader"
    mov si,MSG
    mov cl,0x07         ;set initial cursor horizontial shift
    mov dh,0x07         ;fixed vertical position
    call print_string   
;"Options"
    mov si,BOO
    mov cl,0x10
    mov dh,0x0A
    call print_string
;"Press D"
    mov si,OPA
    mov cl,0x06
    mov dh,0x0C
    call print_string
;"Press any key"
    mov si,OPB
    mov cl,0x05
    mov dh,0x0E
    call print_string
;wait for keyboard input
    mov ah,0x0
    int 16h
;compare key with D and d
    cmp al,0x44 ;D
    je .disk
    cmp al,0x64 ;d
    jne .boot
.disk:
    call load_sector
    jmp .end
.boot:
    mov ah,0x00
    mov al,0x13
    int 10h   
    mov si,PRT
    mov cl,0x05
    mov dh,0x07
    call print_string
    mov si,SOL
    mov cl,0x04
    mov dh,0x09
    call print_string
.end:

load_sector:

print_string:           ; Expects null terminated message in si    
    mov al,[si]
    or al,al
    jz  .end
    inc si
    call update_cursor
    call print_char
    jmp print_string
.end:
    retn

update_cursor:
    mov ah,0x02 ;set mode
    mov dl,cl  ;set position from counter
    int 10h
    inc cl
    retn

print_char:
    mov ah,0x0E         ; Specifies that we want to write a character to the screen
    mov bl,0x06         ; Specifies output text color.  Not required, but useful to know (Works only in video mode)
    mov bh,0x00         ; Page number.  Leave this alone.
    int 0x10            ; Signal video interrupt to BIOS
    retn

;in text mode, this clears screen to defined color
clrscr:
    mov dx, 0 ; Set cursor to top left-most corner of screen
    mov bh, 0
    mov ah, 0x2
    int 0x10
    mov cx, 2000 ; print 2000 chars
    mov bh, 0
    mov bl, 0x21 ; green bg/blue fg
    mov al, 0x20 ; blank char
    mov ah, 0x9
    int 0x10
    ret

;data
    MSG db 'BOOT...wait for it...LOADER',0x0A,0
    BOO db 'Options:',0x0D,0
    OPA db 'Press D to enter disk manager',0x20,0
    OPB db 'Press any key to boot something',0x20,0
    PRT db 'We are entering protected mode',0x20,0
    SOL db 'May God have mercy on our soules',0x20,0

TIMES 510 - ($ - $$) db 0
DW 0xAA55


