[BITS 16]
[org 0x7E00] ;starting point in memory to which program should be loaded

start:
                    ;attempt to start video mode
    mov ah,0x00
    mov al,0x13
    int 10h
    
    mov cl,3        ;center horizontal
    mov dh,7        ;move to fourth line
    mov si,MSG      
    call print_string
    retf

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

;data
    MSG db 'Well...this is really embarrassing',0x0A,0

TIMES 512 - ($ - $$) db 0