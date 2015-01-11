;to assemble:
;nasm -f elf crypt.asm
;to link:
;ld -m elf_i386 -s -o crypt crypt.o


section			.data

greeting		db 'Welcome to the XOR Cipher',0xa	;Intro to the program
greetingLen 	equ $ - greeting					;Length of the intro

messageInput    db 'Enter a message to encode: '	;Input the message prompt
messageInputLen	equ $ - messageInput 				;Length of message prompt

keyInput		db 'Enter a key: '					;Key prompt
keyInputLen		equ $ - keyInput 					;Length of key prompt

encryptOutput	db 'The encrypted message is: ', 10	;Message output
encryptOutputL  equ $ - encryptOutput 				;Length of Message Output

decryptOutput	db 'The decrypted message is: ', 10	;Message output
decryptOutputL  equ $ - decryptOutput 				;Length of Message Output

newLine			db 0xA 								;newLine Character
newLineLen		equ $ - newLine 					;Length of the character


section			.bss

message			resb 51				;reserved 51 bytes for user message
key				resb 51				;reserved 51 bytes for user encryption key
encrypted		resb 51				;reserved 51 bytes for encrypted message
decrypted		resb 51				;reserved 51 bytes for decrypted message


section			.text

global 			_start

_start:

				;------------------------------------Greet User

	outputGreeting:
				mov eax, 4							;Set the sys_call to write
				mov ebx, 1							;Set the output to console
				mov ecx, greeting
				mov edx, greetingLen				;Print the Intro
				int 0x80							;Call the Kernel

				;------------------------------------Request Message

	messageRequest:	
				mov eax, 4							;Set the sys_call to write
				mov ebx, 1							;Set the output to console
				mov ecx, messageInput
				mov edx, messageInputLen
				int 0x80							;Call the Kernel

				;------------------------------------Store Message in Variable
	
	getMessage:	
				mov eax, 3							;set the sys_call to read
				mov ebx, 0
				mov ecx, message 					;variable holding message
				mov edx, 51							;Max length to read
				int 0x80							;call the kernel

				;------------------------------------Request Key

	keyRequest:
				mov eax, 4							;set the sys_call to write
				mov ebx, 1							;set the output to console
				mov ecx, keyInput 					
				mov edx, keyInputLen				
				int 0x80							;Call the Kernel

				;------------------------------------Store key in variable

	getKey:
				mov eax, 3							;set the sys_call to read
				mov ebx, 1							
				mov ecx, key 						;variable holding the key
				mov edx, 51							;Max length to read
				int 0x80							;call the kernel

	;incrementing through the String and performing the cipher on each element
	
 
				mov ecx, message 					;Pass params to function
				mov ebx, key
				mov edx, encrypted
				call cipher
	
    			;------------------------------------Announce the encrypted Msg

	EncryptedMessage:
				mov eax, 4							;set the sys_call to write
				mov ebx, 1							;set the output to console
				mov ecx, encryptOutput
				mov edx, encryptOutputL
				int 0x80

				;------------------------------------Print encrypted msg	

	printEncrypted:
				mov eax, 4							;sys_call to write
				mov ebx, 1							;write to console
				mov ecx, encrypted 					;write the encrypted message
				mov edx, 51							;max length of 51 bytes
				int 0x80							;call the kernel

				;-----------------------------Print a new Line for cleanliness

	printNewLine:
				mov eax, 4							;sys_call to write
				mov ebx, 1							;write to console
				mov ecx, newLine 					;write the newLine char
				mov edx, newLineLen					;length of char
				int 0x80							;call the kernel

	;Perform the cipher (xor) on the encrypted message using key to undo effect

				mov ecx, encrypted 					;Pass params to function
				mov ebx, key
				mov edx, decrypted
				call cipher

    			;------------------------------------announce decrypted Msg

	DecryptedMessage:
				mov eax, 4							;set the sys_call to write
				mov ebx, 1							;set the output to console
				mov ecx, decryptOutput
				mov edx, decryptOutputL
				int 0x80

				;------------------------------------Print the decrypted msg

	printDecrypted:
				mov eax, 4							;sys_call to write
				mov ebx, 1							;write to console
				mov ecx, decrypted 					;write the decrypted message
				mov edx, 51							;max length of 51 bytes
				int 0x80							;call the kernel

				;-----------------------------Print a new Line for cleanliness

	printNextNewLine:
				mov eax, 4							;sys_call to write
				mov ebx, 1							;write to console
				mov ecx, newLine 					;write the newLine char
				mov edx, newLineLen					;length of char
				int 0x80							;call the kernel

				;------------------------------------Exit program with code 0

	exitTheProgram:
				mov eax, 1							;System exit
				mov ebx, 0
				int 0x80							;call the kernel


	cipher:
				pushfd
		start:
				mov al, [ecx]
				mov ah, [ebx]						;get first chars
    			inc ecx
    			inc ebx  							;increment addresses
  				cmp al, 0  							;check for null character
    			je done								;if null, exit
    			xor al, ah							;Perform the cipher
    			mov [edx], al						;Put the char into result
    			inc edx								;increment edx address
    			jmp start 							;Back to top
    	done:
    			popfd
    			ret