; @echo off
; tasm /m5 kbi2.bat
; tlink /x/t kbi2.obj
; del kbi2.obj
; exit
	.model tiny
	.386
	.code
	org 100h
_:	jmp start
scancode db -1
keypress db 0
hip dw 0, 0
int9_handler:
	sti
	push ax
	push bx
	push ds

	push cs
	pop ds
	
	in al, 60h
	mov scancode, al

;	does not work in virtualbox
;	in al, 61h 
;	or al, 10000000b
;	out 61h, al
;	and al, 01111111b
;	out 61h, al

	xor bx, bx
	mov bl, scancode
	call printnum

	mov al, 20h
	out 20h, al ; Virtualbox triggers keyboard here

	mov ah, 02h
	mov dl, ' '
	int 21h
	pop ds
	pop bx
	pop ax
	iret
start:
	
	xor ax, ax
	push es
	push 0
	pop es
	mov ax, word ptr [es:36]
	mov hip, ax	; save old ip of original handler
	mov ax, word ptr [es:38]
	mov hip+2, ax ; save old cs
	cli
	mov ax, offset int9_handler	
	mov [es:36], ax
	mov ax, cs
	mov [es:38], ax
	sti
	pop es
	mov byte ptr keypress, 0
lp0:
	cmp scancode, 82h
	jne lp0
	cli
exit:
	mov byte ptr keypress, 0
	mov ax, word ptr hip
	mov bx, word ptr hip+2
	push es
	push 0
	pop es
	mov word ptr [es:36], ax
	mov word ptr [es:38], bx
;	lea dx, start
;	int 27h
	pop es
	ret
buf db ""
hexsym db "0123456789abcdef"
printnum:
	push bx
	push ax
	push cx	
	mov bh, 0
	mov ah, 02h
	mov cx, bx
	shr bx, 4
	;add bx, 48
	mov dl, [hexsym + bx]
	int 21h	
	shl bx, 4
	sub cx, bx

	mov bx, cx
	mov dl, [hexsym + bx]
	int 21h
	pop cx
	pop ax
	pop bx
	ret
end _