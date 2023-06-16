; @echo off
; tasm /m5 pci.bat
; tlink /x/t pci.obj
; del pci.obj
; exit
	.model tiny
	.386
	.code
	org 100h
_:	jmp start
str_vendor db "Vendor ID: ",'$'	
str_device db "Device ID: ", '$'
str_vendor_info db "Vendor info: ", '$'
str_device_info db "Device info: ", '$'

str_start db "-------------------------------------------------------------------------------",'$'

start:
	xor ebx, ebx
	xor eax, eax
lp:	xor bh, bh
dev:	xor al, al
func:

	; set 23-16 bits to bus number
	xor ecx, ecx 
	mov cl, bl
	shl ecx, 16
	; set 15-11 bits to device and 10-8 to function number
	push bx
	shl bh, 3
	or bh, al
	or ch, bh
	pop bx

	or ecx,  080000000h ; enable bit
	
	
	push ax
	xchg eax, ecx ; move config_address to eax
		      ; and save function number to cl
	mov dx, 0cf8h
	out dx, eax

	mov dx, 0cfch
	in eax, dx
	cmp ax, 0ffffh
	je noprint
	mov cx, ax
	pop ax

	push ax
	push bx
	push dx
	mov ah, 09h
	mov dx, offset str_start
	int 21h
	call nl
	call printnum ; bus
	mov bl, bh
	call sps
	call printnum ; device
	pop dx
	pop bx
	pop ax
	
	push bx
	call sps
	mov bl, al
	call printnum ; func
	call sps
	pop bx
	
	push ax	
	mov ax, cx
	push bx

	mov bx, ax	
	push bx ; store vendor number
	mov bx, ax
	mov dl, 2
	call storenum
	mov dl, 0
	mov bl, bh
	call storenum	
	
	pop bx

	
	push ax
	mov ah, 09h
	mov dx, offset str_vendor
	int 21h
	pop ax
	
	call printnum2 ; print vendor
	call sps
	shr eax, 16
	mov bx, ax
	
	push bx ; store device number
	mov dl, 7
	call storenum
	mov dl, 5
	mov bl, bh
	call storenum
	pop bx

	push dx
	mov ah, 09h
	mov dx, offset str_device
	int 21h
	pop dx

	call printnum2 ; print device
	call nl	
		
	mov ah, 3Dh
	mov al, 010b
	mov dx, offset filename
	int 21h

;	call nl
	
	mov bx, offset buffer
	xor dx, dx
	lp_empty:
		push bx
		add bx, dx
		mov byte ptr [bx], 0
		mov byte ptr [bx+62], 0 ; clear buffer for vendor and device
		pop bx
		inc dx
		cmp dx, 60
		jne lp_empty

	mov bx, ax ; file handler
	mov ah, 3Fh
	mov cx, 60
	mov dx, offset buffer
	int 21h
	
	mov ah, 09h
	mov dx, offset str_device_info
	int 21h
	mov dx, offset buffer
	int 21h
;	call nl

	; print vendor info
	mov ah, 3Dh	
	mov al, 010b
	mov byte ptr [filename + 17], 'n'
	mov byte ptr [filename + 18], 'a'
	mov byte ptr [filename + 19], 'm'
	mov byte ptr [filename + 20], 'e'


	mov dx, offset filename
	int 21h
	
	mov bx, ax
	mov ah, 3Fh
	mov cx, 60
	mov dx, offset buffer2
	int 21h
	mov ah, 09h
	call nl
	mov dx, offset str_vendor_info
	int 21h
	mov dx, offset buffer2
	int 21h

	mov ah, 3Eh
	int 21h ; close file handler in bx
	
	call nl
	pop bx
noprint:
	pop ax


	inc al ; func
	cmp al, 8
	jne func

	inc bh ; device
	cmp bh, 32
	jne dev

	inc bl ; bus
	jnz lp 
	mov ah, 0
	int 21h
	ret
; 13 offset
buffer  db 61 dup (0), '$'
buffer2 db 61 dup (0), '$'
filename db "C:\WORK5\DB\0000\0000", 0, "$"
hexsym db "0123456789abcdef"
nl: ; new line
	push ax
	push dx
	mov ah, 02h
	mov dl, 13
	int 21h
	mov dl, 10
	int 21h
	pop dx
	pop ax
	ret
sps: ; space
	push ax
	push dx
	mov ah, 02h
	mov dl, ' '
	int 21h
	pop dx
	pop ax
	ret
printnum2:
	push ax
	push bx
	mov ah, bl
	mov bl, bh
	call printnum
	mov bl, ah
	call printnum
	pop bx
	pop ax
	ret

storenum:
	push bx
	push ax
	push cx
	push dx
	add dl, 12 ; offset after C:\WORK5..

	mov bh, 0
	mov ah, 02h
	mov cx, bx
	shr bx, 4
	xor ax,ax
	mov al, [hexsym + bx]
	;xor bx, bx
	
	push bx
	xor bx, bx
	add bl, dl
	add bx, offset filename
	mov byte ptr [bx], al
	pop bx
	shl bx, 4
	sub cx, bx
	
	mov bx, cx
	mov al, [hexsym + bx]
	xor bx, bx
	add bl, dl
	inc bl
	add bx, offset filename
	mov byte ptr [bx], al

	pop dx
	pop cx
	pop ax
	pop bx
	ret

printnum:
	push bx
	push ax
	push cx	
	push dx
	mov bh, 0
	mov ah, 02h
	mov cx, bx
	shr bx, 4
	mov dl, [hexsym + bx]
	int 21h	
	shl bx, 4
	sub cx, bx

	mov bx, cx
	mov dl, [hexsym + bx]
	int 21h
	pop dx
	pop cx
	pop ax
	pop bx
	ret
end _
