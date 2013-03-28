[BITS 16]
[org 0x7C00]

start:
    ;attempt to start video mode - we have to look fancy!
    mov ah,0x00
    mov al,0x13
    int 10h

    ;this should handle the A20 line
    call check_a20 
    cmp ax,0x01
    je .skip            ;if A20 is enabled, skip 
    in al, 0x92         ;should enable A20 line, but works only on new IBM PS/2 systems - needs replacement??
    or al, 2
    out 0x92, al
.skip:

    ;some basic stupid text printing
    call welcome_user

    ;wait for keyboard input
    mov ah,0x0
    int 16h

    ;compare key with D and d
    cmp al,0x44 ;D
    je .disk            ;if D, jump to disk manager loader, if not, test d
    cmp al,0x64 ;d
    jne .boot           ;if d, do nothing and proceed to disk manager loader, if no, jump to boot sequence
.disk:

    ;fill segment register where disk util should be loaded
    mov bx,[LOC]    ;ES cant be loaded directly...
    shr bx,4        ;shift by 4 bits makes correction from physical adress to segment address
    mov es,bx

    ;set number of sector where disk util is stored
    mov cl,0x02
    call load_sector
    ;start disk util

    jmp [LOC]  

.boot:

    ;switch to text mode - bootloader can be fancy, but OS - no way! (kiddn' we just dont have graphics drivers yet...)
    mov ah,0x00
    mov al,0x03
    int 10h

    ;setup segment register and sector number to and from to read the chainloader
    mov bx,[CHAIN]
    shr bx,4
    mov es,bx
    mov cl,0x03
    call load_sector

    jmp [CHAIN]

    jmp $

;FUNCTIONS

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
    mov al,0x03 ;num of sectors
    ;CX =       ---CH--- ---CL---
    ;cylinder : 76543210 98
    ;sector   :            543210
    mov ch,0x00 
    ;mov cl,0x02 
    mov dh,0x00 ;head
    mov dl,0x80 ;0x80-primary disk 0x81-secondary disk, 0x00-1st floppy...
    ;mov bx,[LOC]    ;ES cant be loaded directly...
    ;shr bx,4        ;shift by 4 bits makes correction from complete adress to segment address
    ;mov es,bx
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

;Checks whether A20 is enabled - taken from osdev wiki
check_a20:
    pushf
    push ds
    push es
    push di
    push si
    cli 
    xor ax, ax ; ax = 0
    mov es, ax
    not ax ; ax = 0xFFFF
    mov ds, ax
    mov di, 0x0500
    mov si, 0x0510 
    mov al, byte [es:di]
    push ax 
    mov al, byte [ds:si]
    push ax 
    mov byte [es:di], 0x00
    mov byte [ds:si], 0xFF
    cmp byte [es:di], 0xFF
    pop ax
    mov byte [ds:si], al
    pop ax
    mov byte [es:di], al 
    mov ax, 0
    je check_a20__exit 
    mov ax, 1
check_a20__exit:
    pop si
    pop di
    pop es
    pop ds
    popf
    ret

;data
    MSG db 'BOOT...wait for it...LOADER',0
    BOO db 'Options:',0
    OPA db 'Press D to enter disk manager',0
    OPB db 'Press any key to boot something',0
    LOC dw 0x7E00   ;disk utility memory positon
    COLOR db 0x06   ;text color
    CHAIN dw 0x0600  ;relocator position

TIMES 446 - ($ - $$) db 0 ;fills the rest of the file until position 446 with 0x00 (not sure how works)
;add one FAT partition record containing our OS to MBR
db 0x80 ;bootable
db 0xFE ; create invalid start head/cylinder entry - really pointless these days
db 0xFF
db 0xFF
db 0x0C ;LBA-mapped FAT32
db 0xFE ;invalid ending entry
db 0xFF
db 0xFF
db 0x08 ;leave 3 free segments for bootlaoder (and also align partition to the 4kb block)
db 0x00
db 0x00
db 0x00
db 0xBE ;assign 40MB of 512 sectors for this partition
db 0x38
db 0x01
db 0x00
TIMES 510 - ($ - $$) db 0 ;fills the rest of the file until position 446 with 0x00 (not sure how works)
DW 0xAA55 ;add boot sector bytes
