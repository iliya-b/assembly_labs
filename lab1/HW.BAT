; @echo off
; goto l1
	.model tiny
	.386
	.code
	org 100h
_:	jmp start
strochka db "Hello, world!",13,10,'$'	
start:
        mov ax, 0B800h
        mov es, ax
        mov di, 6
        mov cx, 255
 
lp1:
	mov ax, 255
	sub al, cl ; al is ascii code 0...255	
	; Print  1st digit
	
	mov bl, 100
	div bl	
	mov bh, ah
	mov ah, 4
 	add al, 48
        mov word ptr [es:di], ax
	; Print 2nd digit
	mov ax, 0
	add di, 2
	mov al, bh
	mov bl, 10
	div bl
	mov bh, ah 
	mov ah, 4
	add al, 48
	mov word ptr [es:di], ax
	; Print 3rd digit
	add di, 2
	mov al, bh
	mov ah, 4
	add al, 48
	mov word ptr [es:di], ax
	; Print the character
	add di, 4
	mov al, 255
	sub al, cl
	mov ah, 4
	mov word ptr [es:di], ax
	; New line
	mov bx, 160
	add di, 152
	mov ax, di
	mov dx, 0
	div bx
	cmp ax, 23
	jne iter
	mov di, 2*6
	add di, dx
iter:   
	cmp cx, 0
	je finish
	dec cx
        jmp lp1
finish:
	ret
        db (510-($-_)) dup(0)
        db 55h, 0AAh

end _
; :l1
;	tasm /m5 hw.bat
;	tlink /x/t hw.obj
;	del hw.obj
