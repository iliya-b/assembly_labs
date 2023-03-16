; @echo off
; tasm /m5 write_fl.bat
; tlink /x/t write_fl.obj
; del write_fl.obj
; exit
	.model tiny
	.386
	.code
	org 100h
_:	jmp start
fname db "HW.COM",0
start:
	mov ah, 03Dh
	mov al, 0
	lea dx, fname
	int 21h

	mov bx, ax
	mov ah, 3Fh
	mov cx, 200h
	lea dx,  mem
	int 21h
	
	mov ah, 3Eh
	int 21h

	mov ah, 03h
	mov al, 1
	mov ch, 0
	mov cl, 1
	mov dh, 0
	mov dl, 0
	; :: mov  ax, 0
	; :: mov es, ax
	lea bx, mem
	int 13h
	ret


mem	db 512 dup(0)
end _