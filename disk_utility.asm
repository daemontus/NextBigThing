[BITS 16]
[org 0x7C00]

start:
;attempt to start video mode
    mov ah,0x00
    mov al,0x13
    int 10h

    mov si,MSG
    call print_string

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
;data
    MSG db 'Well...this is embarrassing',0x0A,0
