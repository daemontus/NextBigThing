[BITS 16]
[org 0x0600] ;starting point in memory to which program should be loaded

;in the future, this HAS TO decide, based on MBR(and maybe data from first stage), which partition to load - now we have hardcoded sector 9
start:
	call load_sector
	jmp [LOC]
	retf

load_sector:                ;later rewrite to accept custom disc/memory locations
    mov ah,0x02 ;read  
    mov al,0x01 ;num of sectors
    ;CX =       ---CH--- ---CL---
    ;cylinder : 76543210 98
    ;sector   :            543210
    mov ch,0x00 
    mov cl,0x09 
    mov dh,0x00 ;head
    mov dl,0x80 ;0x80-primary disk 0x81-secondary disk, 0x00-1st floppy...
    mov bx,[LOC]    ;ES cant be loaded directly...
    shr bx,4        ;shift by 4 bits makes correction from complete adress to segment address
    mov es,bx
    mov bx,0x00 ;buffer offset 0
    int 13h
    retn


;prits one char from al to screen on cursor position
print_char:
    mov ah,0x0E         ; Specifies that we want to write a character to the screen
    mov bl,[COLOR]      ; Specifies output text color.  Not required, but useful to know (Works only in video mode)
    mov bh,0x00         ; Page number.  Leave this alone.
    int 0x10            ; Signal video interrupt to BIOS
    retn

;data 
LOC dw 0x7C00
COLOR db 0x06   ;text color
