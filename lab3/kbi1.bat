; @echo off
; tasm /m5 kbi1.bat
; tlink /x/t kbi1.obj
; del kbi1.obj
; exit
	.model tiny
	.386
	.code
	org 100h
_:	jmp start
strochka db "Hello, world!",13,10,'$'	
scancode db -1
keypress db 0
hip dw 0, 0
int9_handler:
	inc byte ptr keypress
	jmp dword ptr cs:hip
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

	mov ax, offset int9_handler	
	mov [es:36], ax
	mov ax, cs
	mov [es:38], ax
	pop es
	mov byte ptr keypress, 0
lp0:
	cmp byte ptr keypress, 2
	jb lp0
	mov byte ptr keypress, 0
	push es
	push 0
	pop es	
	mov ax, [es:41Ah] ;head
	mov cx, [es:41Ch] ;tail
	
	mov bx, ax
	add bx, 0400h
	mov bx, [es:bx]
	pop es
	cmp bl, '1'
	je exit
	push ax
	mov ah, 02h
	mov dl, 09h ; tab
	int 21h
	mov dl, bl  ; character
	int 21h
	mov dl, 45 ; space
	int 21h
	mov bl, bh
	call printnum ; scancode
	pop ax
	push es
	push 0
	pop es
	mov [es:41Ch], ax	
	pop es
	jmp lp0	

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
