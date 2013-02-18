[BITS 16]
[org 0x7C00]

start:
        ;attempt to start video mode - we have to look fancy!
    mov ah,0x00
    mov al,0x13
    int 10h
    call welcome_user
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
    jmp [LOC]  
.boot:
        ;here is going to be code to start protected mode and load kernel, for now, only crappy jokes
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
    jmp $

;FUNTIONS

;just prints all the welcome strings at once so they dont mess up in "main" function
welcome_user:
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
    retn

;needs defined initial vertical and horizontal cursor position in cl and dh
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
    
;BIOS INTERRUPT FUNCTIONS

load_sector:                ;later rewrite to accept custom disc/memory locations
    mov ah,0x02 ;read  
    mov al,0x02 ;num of sectors
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

;sets cursor to next position, does not change dh(vertical value)
update_cursor:
    mov ah,0x02 ;set mode
    mov dl,cl  ;set position from counter
    int 10h
    inc cl
    retn

;prits one char from al to screen on cursor position
print_char:
    mov ah,0x0E         ; Specifies that we want to write a character to the screen
    mov bl,[COLOR]      ; Specifies output text color.  Not required, but useful to know (Works only in video mode)
    mov bh,0x00         ; Page number.  Leave this alone.
    int 0x10            ; Signal video interrupt to BIOS
    retn

;data
    MSG db 'BOOT...wait for it...LOADER',0
    BOO db 'Options:',0
    OPA db 'Press D to enter disk manager',0
    OPB db 'Press any key to boot something',0
    PRT db 'We are entering protected mode',0
    SOL db 'May God have mercy on our soules',0
    LOC dw 0x7E00   ;disk utility memory positon
    COLOR db 0x06   ;text color

stop:

TIMES 510 - ($ - $$) db 0 ;fills the rest of the file until position 510 with 0x00 (not sure how works)
DW 0xAA55 ;add boot sector bytes
