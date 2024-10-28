%define EXIT_SUCCESS 0

%define SYS_WRITE 1
%define SYS_EXIT  0x3c

%define FD_STDIN  0
%define FD_STDOUT 1

%macro read 3
	xor rax, rax
	mov rdi, %1
	mov rsi, %2
	mov rdx, %3
	syscall
%endmacro

%macro write 3
	mov rax, SYS_WRITE
	mov rdi, %1
	mov rsi, %2
	mov rdx, %3
	syscall
%endmacro

%macro exit 1
	mov rax, SYS_EXIT
	mov rdi, %1
	syscall
%endmacro
