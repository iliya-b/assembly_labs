; @echo off
; tasm /m5 tracer.bat
; tlink /x/t tracer.obj
; del tracer.obj
; exit
	.model tiny
	.386
	.code
	org 100h
_:	jmp start

h4:
	ror bx, 8
	call h2
	ror bx, 8
	
h2:	mov al, bl
	shr al, 4
	call h1
	mov al, bl
h1:	and ax, 0fh
	cmp al, 10
	sbb al, 69h
	das
	stosb
	ret
stroka db '0000',13,10,'$'
int1_handler:
	push bp
	push bx
	push di
	push dx
	push ax
	push ds

	push cs
	pop ds

	mov bp, sp
	mov bx, [bp+6*2]
	lea di, stroka
	call h4
	lea dx, stroka
	mov ah, 09h
	int 21h
	
	pop ds
	pop ax
	pop dx
	pop di
	pop bx
	pop bp
	iret

fname db "hw.com",0
errormes db "Error",13,10,'$'
finish db "Finished",13,10,'$'
start:
	mov ah, 3Dh
	mov al, 00h
	lea dx, fname 
	int 21h
	je go_to_error
	mov bx, ax
	mov ah, 3Fh
	mov cx, 256
	lea dx, program
	int 21h
	mov ah, 3Eh
	int 21h

	; int 1 handler
	xor ax, ax
	push ax
	pop es
	mov ax, offset int1_handler
	mov [es:4], ax
	mov ax, cs
	mov [es:6], ax
	push ds
	pop es
	
	push cs
	mov ax, offset after_run
	push ax
	xor ax, ax
	push ax 

	mov dx, cs	
	mov ax, offset peb
	shr ax, 4
	add dx, ax
	mov ds, dx

	pushf
	pop ax
	or ax, 100000000b
	push ax	; new flags
	push dx ; new cs
	push 100h ; new ip
	iret
	ret

after_run:
	mov dx, cs
	mov ds, dx
	lea dx, finish
	mov ah, 09h
	int 21h
	ret
go_to_error:
	mov ah, 09h
	lea dx, fname
 
	int 21h
align 16
peb:
	retf
	db 255 dup(0)
program db 256 dup(0)
end _