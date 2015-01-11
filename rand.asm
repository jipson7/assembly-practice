;to assemble:
;nasm -f elf rand.asm -l rand.lst
;note: -l rand.lst is optional if debugging
;to link:
;gcc -nostartfiles rand.o -o rand -lc -m32

section 		.data

newLine 		db 0xA
newLineLen		equ $ - newLine

message			db 'The random number is: '
messageLen		equ $ - message

section			.bss

random			resb 4				
output 			resb 4 
decimalOutput   resb 4	

section			.text

global			_start

_start:

		displayMessage:

				mov eax, 4
				mov ebx, 1
				mov ecx, message
				mov edx, messageLen
				int 0x80

		getSystemTime:
				mov eax, 13
				push eax
				mov ebx, esp
				int 0x80
				pop eax
				mov [random], eax

		divideForRemainder:
				mov ecx, 10d
				xor edx, edx
				xor eax, eax
				mov eax, [random]
				div ecx
				mov [output], edx

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
