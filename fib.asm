;to assemble:
;nasm -f elf fib.asm -l fib.lst
;to link:
;gcc -nostartfiles fib.o -o fib -lc -m32


section			.data

numberMessage		db 'Enter A Number',0xa				;Intro to the program
numberMessageLen 	equ $ - numberMessage				;Length of the intro

fibMessage 		db 'The nth term is: '
fibMessageLen 	equ $ - fibMessage 				;Length of message

newLine			db 0xA
newLineLen		equ $ - newLine


section 		.bss

number 			resb 4								;reserve bytes for input
decimalNumber 	resb 4								;reserve bytes for input
output 			resb 4								;reserve bytes for output
decimalOutput   resb 4

section 		.text

global			_start

_start:


	askForNumber:
				mov eax, 4 							;sys call for write
				mov ebx, 1 							;output to console
				mov ecx, numberMessage 					;The message
				mov edx, numberMessageLen				;The message length
				int 0x80 							;call the kernel

	inputNumber:
				mov eax, 3 							;sys call for read
				mov ebx, 0 							;user defined entry
				mov ecx, number 					;input into number
				mov edx, 4						;max length of int
				int 0x80 							;call the kernel


				call atoi

	fib:
				mov edi, 1d 							;initialize counter
				mov ecx, 0d 							;First fibonacci number
				mov edx, 1d 							;second fib number
				mov eax, [decimalNumber]
		start:
				cmp edi, eax 						; check
				je done
				mov esi, edx
				add edx, ecx 
				mov ecx, esi
				inc edi							;increment the counter
				jmp start
		done:
				mov [output], edx

	outputMessage:
				mov eax, 4
				mov ebx, 1
				mov ecx, fibMessage
				mov edx, fibMessageLen
				int 0x80

	convertDecimal:
				push '$'						;designate a stack base
				mov eax, [output]
		conversion:
				mov [output], eax
				mov edx, 0
				mov ecx, 10						;divide by 10 to separate
				idiv ecx						
				add edx, 0x30					;convert to ascii
				push edx 						;remainder onto stack
				mov [output], eax 				; put back into output
				cmp eax, 0
				jnz conversion					;when eax ==0, break loop
		printDecimal:
				pop eax
				mov [decimalOutput], eax		
				cmp eax, '$'					;back at stack base?
				je outPutnewLine						;If so were done
				mov eax, 4 						;Syswrite
				mov ebx, 1 						; to console
				mov ecx, decimalOutput 			;
				mov edx, 1 						;Only print 1 byte at a time
				int 0x80 						;call kernel
				jmp printDecimal

		outPutnewLine:
				mov eax, 4
				mov ebx, 1
				mov ecx, newLine
				mov edx, newLineLen
				int 0x80




	sysExit:

				mov eax, 1
				mov ebx, 0
				int 0x80

	atoi:
				mov ecx, number
				mov eax, 0
				mov ebx, 0
				mov esi, 10
		top:	
				mov bl, [ecx]
				inc ecx
				cmp bl, '0'
				jb superdone
				cmp bl, '9'
				ja superdone
				sub bl, '0'
				mul esi
				add eax, ebx
				jmp top
		superdone:
				mov [decimalNumber], eax
				ret