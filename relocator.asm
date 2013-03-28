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

[BITS 32]
TIMES 128 - ($ - $$) db 0;
;Interrupt handler 1
mov dword [0xb8000], 0x07300730
iret
TIMES 192 - ($ - $$) db 0;
;Interrupt handler 2
mov dword [0xb8000], 0x07310730
iret
TIMES 256 - ($ - $$) db 0;
;Interrupt handler 3
mov dword [0xb8000], 0x07320730
iret
TIMES 320 - ($ - $$) db 0;
;Interrupt handler 4
mov dword [0xb8000], 0x07330730
iret
TIMES 384 - ($ - $$) db 0;
;Interrupt handler 5
mov dword [0xb8000], 0x07340730
iret
TIMES 448 - ($ - $$) db 0;
;Interrupt handler 6
mov dword [0xb8000], 0x07350730
iret
TIMES 512 - ($ - $$) db 0;
;Interrupt handler 7
mov dword [0xb8000], 0x07360730
iret
TIMES 576 - ($ - $$) db 0;
;Interrupt handler 8
mov dword [0xb8000], 0x07370730
iret
TIMES 640 - ($ - $$) db 0;
;Interrupt handler 9
mov dword [0xb8004], 0x07380730
iret
TIMES 704 - ($ - $$) db 0;
;Interrupt handler 10
mov dword [0xb8000], 0x07390730
iret
TIMES 768 - ($ - $$) db 0;
;Interrupt handler 11
mov dword [0xb8000], 0x07310730
iret
TIMES 832 - ($ - $$) db 0;
;Interrupt handler 12
mov dword [0xb8000], 0x07310731
iret
TIMES 896 - ($ - $$) db 0;
;Interrupt handler 13
mov dword [0xb8000], 0x07310732
iret
TIMES 960 - ($ - $$) db 0;
;Interrupt handler 14
mov dword [0xb8000], 0x07310733
iret
TIMES 1024 - ($ - $$) db 0;
;Interrupt handler 15
mov dword [0xb8000], 0x07310734
iret
TIMES 1088 - ($ - $$) db 0;
;Interrupt handler 16
mov dword [0xb8000], 0x07310735
iret
TIMES 1152 - ($ - $$) db 0;
;Interrupt handler 17
mov dword [0xb8000], 0x07310736
iret
TIMES 1216 - ($ - $$) db 0;
;Interrupt handler 18
mov dword [0xb8000], 0x07310737
iret
TIMES 1280 - ($ - $$) db 0;
;Interrupt handler 19
mov dword [0xb8000], 0x07310738
iret
TIMES 1344 - ($ - $$) db 0;
;Interrupt handler 20
mov dword [0xb8000], 0x07310739
