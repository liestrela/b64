; b64 - Base64 encoder/decoder based on RFC 4648

section .data
alpha db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
endl  db 0xa

section .bss
in_b  resb 3
out_b resb 4

section .text
global _start

%include "linux.inc"

encode_blk:
	xor edx, edx
	xor ecx, ecx

	mov dl, byte [in_b]
	shr dl, 2
	mov si, dx
	mov cl, [alpha+esi]
	mov [out_b], cl
	
	mov dl, byte [in_b]
	and dl, 3
	shl dl, 4
	mov cl, byte [in_b+1]
	and cl, 0xf0
	shr cl, 4
	or dl, cl
	mov si, dx
	mov cl, [alpha+esi]
	mov [out_b+1], cl

	cmp rbx, 1
	jle _pad1
	
	mov dl, byte [in_b+1]
	and dl, 0x0f
	shl dl, 2
	mov cl, byte [in_b+2]
	and cl, 0xc0
	shr cl, 6
	or dl, cl
	mov si, dx
	mov cl, [alpha+esi]
	mov [out_b+2], cl

_out3ret:
	cmp rbx, 2
	jle _pad2

	mov dl, byte [in_b+2]
	and dl, 0x3f
	mov si, dx
	mov cl, [alpha+esi]
	mov [out_b+3], cl
_out4ret:
	ret
_pad1:
	mov cl, 61
	mov byte [out_b+2], cl
	jmp _out3ret
_pad2:
	mov cl, 61
	mov byte [out_b+3], cl
	jmp _out4ret

_break0:
	mov esi, dword [rsp-8]
	mov byte [in_b+esi], 0
	jmp _breakret

_start:
	xor eax, eax

	mov [rsp-4], eax ; len = 0
	mov [rsp-8], eax ; i = 0
	
	_loop0:
	mov rbx, rsp
	sub rbx, 9 ; [rsp-9] = c
	read FD_STDIN, rbx, 1
	cmp rax, 0
	jz _break0
	
	mov esi, dword [rsp-8]
	mov bl, byte [rsp-9]
	mov byte [in_b+esi], bl
	inc dword [rsp-4]
	_breakret:
	inc dword [rsp-8]

	cmp dword [rsp-8], 3
	jl _loop0

	cmp dword [rsp-8], 0
	jl _start

	mov ebx, [rsp-4]
	call encode_blk

	push rax
	write FD_STDOUT, out_b, 4
	pop rax

	cmp rax, 0
	jnz _start

	_end:
	write FD_STDOUT, endl, 1
	exit EXIT_SUCCESS
