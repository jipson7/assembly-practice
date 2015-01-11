;Caleb Phillips 100518555


;to assemble
;rename file to main.asm and...
;nasm -f elf main.asm -o main.o
;
;to link
;gcc -nostartfiles main.o -o main -m32

section .bss
  num: resw 1 ;placeholder for numbers used in read num conversion
  temp: resb 2  ;place holder
  array1: resw 50 ;Space for actual array
  size1: resw 1 ;How big is array gonna be

  
section .text
  
  lengthPrompt: 	db "Enter the number of elements in the array: "
  lengthPromptLen: 	equ $-lengthPrompt
  
  arrayPrompt:  	db "Enter the elements one by one, each followed by ENTER"
  arrayPromptLen: 	equ $-arrayPrompt
  
  searchItemPrompt:  db "Enter the element to be searched : "
  searchItemPromptLen: equ $-searchItemPrompt
  
  yesMessage: 		db "Found It!"
  yesMessageLen: 	equ $-yesMessage
  
  noMessage: 		db "I could not find that number."
  noMessageLen: 	equ $-noMessage

  newLine:			db 0xA ;To make it look nice...		
  newLineLen:		equ $ - newLine
  
  
  
section .text


global 			_start

_start:

promptInput:
				mov eax, 4
				mov ebx, 1
				mov ecx, lengthPrompt
				mov edx, lengthPromptLen
				int 0x80 			;call the kernel

				mov ecx, 0 		
				call read_num  
				mov cx, word[num]
				mov word[size1], cx

				push ecx

				mov eax, 4 				;Output prompt for array
				mov ebx, 1
				mov ecx, arrayPrompt
				mov edx, arrayPromptLen
				int 0x80 				;call the kernel

				call newLineFormatting

				pop ecx 			;Array Length
				mov eax, 0
				mov ebx, array1
  


read_element:
				call read_num
				mov dx , word[num] ;output from read_num, which is now an int
				mov  word[ebx + 2 * eax], dx ;store it in the actual array
				inc eax    ;Incrementing array index by one
				loop read_element 

				; Ask what value we're searchin for
				mov eax, 4
				mov ebx, 1
				mov ecx, searchItemPrompt
				mov edx, searchItemPromptLen
				int 80h


				call read_num ; we have to convert the search to an int to use
				mov ax, word[num] 

				
				 CLD ;clear direction flag, so it increments, not decrements
				 mov  edi, array1 ;Copy Base address of array to index reg
				 mov  ecx, 10 

linearSearch:
				SCASW ;Used to compare word in AX to ES:EDI,sets flag
				je found
				loop linearSearch
				mov eax, 4
				mov ebx, 1
				mov ecx, noMessage
				mov edx, noMessageLen
				int 0x80		;call the kernel
				jmp sysExit
       
      
found:
				mov eax, 4
				mov ebx, 1
				mov ecx, yesMessage
				mov edx, yesMessageLen
				int 0x80 		;call the kernel
      

  

sysExit:
	
				call newLineFormatting
				
				mov eax, 1
				mov ebx, 0
				int 0x80 		;call the kernel

  
  
;read_num Reads a number and stores as int rather than ascii
;atoi basically, but I couldnt figure out how to call c in linux properly
;The algorithm is to
;Subtract 48 from character
;Multiply result so far by ten (to make room for new character)
;then add the character into the result so far.

read_num:

				pusha    		;Push all general registers
				mov word[num], 0

	loop_read:
				mov eax, 3 		;sys value for reading
				mov ebx, 0 		; read in from console
				mov ecx, temp	; store in temp
				mov edx, 1 		; max length
				int 0x80 		; cal lthe kernel

				cmp byte[temp], 10
				je end_read

				mov ax, word[num]
				mov bx, 10 		;Multiply by ten to make room for new character
				mul bx
				mov bl, byte[temp]
				sub bl, 30h 		;convert that character to int by subt '0'
				mov bh, 0   		;0 out upper 8 bits of bx
				add ax, bx
				mov word[num], ax
				jmp loop_read 
	end_read:
				popa 			;Pop all the general registers

				ret


newLineFormatting:						;Makes it look way cooler!!!!
				mov eax, 4
				mov ebx, 1
				mov ecx, newLine
				mov edx, newLineLen
				int 0x80 		;call the kernel
				ret