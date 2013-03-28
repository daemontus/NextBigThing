[BITS 16]
[org 0x7C00]

start:
    call load_sector
    lidt [idt_desc] ;load idt
	lgdt [gdt_desc] ;load gdt
	MOV EAX, CR0
	OR AL, 1
	MOV CR0, EAX
	;initialize environment
	mov ax, 10h             ; Save data segment identifyer
    mov ds, ax              ; Move a valid data segment into the data segment register
    mov ss, ax              ; Move a valid data segment into the stack segment register
    mov esp, 0090000h        ; Move the stack pointer to 090000h
    ;mov dword [0xb8000], 0x07300730
    sti
    jmp 0x08:0x1000			;wanted to use LOC instead, but gives "op size not specified" err ?!?!
    ;jmp $
	retf



load_sector:                ;later rewrite to accept custom disc/memory locations
    mov ah,0x02 ;read  
    mov al,0x0A ;num of sectors
    ;CX =       ---CH--- ---CL---
    ;cylinder : 76543210 98
    ;sector   :            543210
    mov ch,0x00 
    mov cl,0x0A
    mov dh,0x00 ;head
    mov dl,0x80 ;0x80-primary disk 0x81-secondary disk, 0x00-1st floppy...
    mov bx,[LOC]    ;ES cant be loaded directly...
    shr bx,4        ;shift by 4 bits makes correction from complete adress to segment address
    mov es,bx
    mov bx,0x00 ;buffer offset 0
    int 13h
    retn

print_char:
    mov ah,0x0E         ; Specifies that we want to write a character to the screen
    mov bl,0x06         ; Specifies output text color.  Not required, but useful to know (Works only in video mode)
    mov bh,0x00         ; Page number.  Leave this alone.
    int 0x10            ; Signal video interrupt to BIOS
    retn

gdt:                    ; Address for the GDT

gdt_null:               ; Null Segment
        dd 0
        dd 0

gdt_code:               ; Code segment, read/execute, nonconforming
        dw 0FFFFh
        dw 0
        db 0
        db 10011010b
        db 11001111b
        db 0

gdt_data:               ; Data segment, read/write, expand down
        dw 0FFFFh
        dw 0
        db 0
        db 10010010b
        db 11001111b
        db 0

gdt_end:                ; Used to calculate the size of the GDT



gdt_desc:                       ; The GDT descriptor
        dw gdt_end - gdt - 1    ; Limit (size)
        dd gdt                  ; Address of the GDT

idt:

zero_div:
        dw 0x680 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_1: 
        dw 0x6C0 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_2:
        dw 0x700 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_3:
        dw 0x740 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_4:
        dw 0x780 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_5:
        dw 0x7C0 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_6:
        dw 0x800 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_7:
        dw 0x840 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_8:
        dw 0x880 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_9:
        dw 0x8C0 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_A:
        dw 0x900 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_B:
        dw 0x940 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_C:
        dw 0x980 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_D:
        dw 0x10C0 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_E:
        dw 0x1100 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_F:
        dw 0x1140 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_10:
        dw 0x1180 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_11:
        dw 0x11C0 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_12:
        dw 0x1200 
        dw 0x8
        db 0
        db 10101110b
        dw 0
INT_13:
        dw 0x1240
        dw 0x8
        db 0
        db 10101110b
        dw 0
idt_end:

idt_desc:
    dw idt_end - idt - 1
    dd idt

 LOC dw 0x1000
