; assembly language program -- Contains 4 different procedures that utilize the stack for passing parameters
; Author:  Ali Mazeh
; Date:    12/11/2016

.586
.MODEL FLAT

INCLUDE io-asm.h            ; header file for input/output

.STACK 4096

.DATA
array		DWORD 10 DUP (?)
number_1	DWORD ?
number_2	DWORD ?
number_3	DWORD ?
nbrInts		DWORD ?
count		DWORD ?
average		DWORD ?
nbrElements DWORD 0
arraySize	DWORD 10

direction1	BYTE "Enter two numbers. Function will find the minimum number.",0
direction2	BYTE "Enter three numbers. Function will find the maximum number.",0
direction3	BYTE "Enter 10 numbers into an array. Function will find the average.",0
direction4	BYTE "Enter a number. Function will search through previous array and return index.",0

resultLbl1	BYTE "The smaller number is: ",0
resultLbl2	BYTE "The larger number is: ",0
resultLbl3	BYTE "The average of all the elements in the array is: ",0
resultLbl4	BYTE "The index of the value is:  ",0

result      BYTE 11 DUP(?),0
mess		BYTE "Value not in array", 0
mess2		BYTE "Array is empty. Ending program", 0
prompt		BYTE "Enter a number.", 0
invalid		BYTE "Invalid number. Try again", 0
full		BYTE "Array is now full.", 0
blank		BYTE ?
number		BYTE 20 DUP (?)

.CODE
_MainProc PROC				
				output	direction1, blank
				input	prompt, number,20 		; get number
				atod	number	
				push	eax						;push 2nd parameter

				input	prompt, number,20 		; get number
				atod	number	
				push	eax						;push the first parameter
					
				call	Min2					;call Proc1				
				add		esp,8					;remove parameters from stack

				dtoa	result, eax				;convert to ASCII character
				output	resultLbl1,result		;output label and result

				output	direction2, blank

				input	prompt, number,20 		; get number
				atod	number	
				push	eax

				input	prompt, number,20 		; get number
				atod	number	
				push	eax

				input	prompt, number,20 		; get number
				atod	number	
				push	eax

				call	Max3				;call Proc2			
				add		esp,12				;remove parameters from stack

				dtoa	result, eax			;convert to ASCII character
				output	resultLbl2,result	;output label and result
				output	direction3, blank

				lea		ebx, array		; load address of array

				whilePos:	input	prompt, number, 20		; get number
							atod	number			; convert to integer
							mov		[ebx], eax		; store num in array
							inc		nbrElements		; increment number of elements
							cmp		nbrElements, 10	; check if array is full
							jz		arrayFull		; jump if array is full
							add		ebx,4			; get next address of array
							jmp		whilePos		; loop

				arrayFull:	output	full, blank		; output message that array is full
							jmp		endWhile		; jump out of loop
				endwhile:
				lea		ebx, array

				lea		eax, average
				push	eax
				push	nbrElements
				lea		eax,array
				push	eax

				call	Avg			; call Proc3
				add		esp,12

				mov		eax, average
				dtoa	result, eax		;convert to ASCII character
				output	resultLbl3,result ;output label and result

				output	direction4, blank

				input	prompt, number,20 		; get number
				atod	number	
				
				push	eax
				push	arraySize
				lea		eax,array
				push	eax

				call	Search		; call Proc4
				add		esp,12

				dtoa	result, eax			;convert to ASCII character
				output	resultLbl4,result	;output label and result

				mov		eax, 0				;exit with return code 0
				ret						;return 					
_MainProc ENDP
												
Min2 PROC	
				push	ebp				; save the base pointer
				mov		ebp,esp			; establish stack frame
				push	ebx				; save ebx
				push	ecx
				push	edx
				pushf

				mov		eax,[ebp+8]		;copy the first parameter to bx
				mov		ebx,[ebp+12]	;copy the second parameter to bx

				cmp		eax, ebx		;compare eax and ebx
				jg		Larger			;jump if eax is greater than ebx
				jl		finish			;jump if eax is smaller than ebx

Larger:			mov		eax, ebx		;copy ebx to eax
				jmp		finish			;unconditionally jump

finish:			popf
				pop		edx
				pop		ecx
				pop     ebx				;restore ebx
				pop		ebp				;restore ebp
				ret			
Min2 ENDP

Max3 PROC	
				push	ebp				; save the base pointer
				mov		ebp,esp			; establish stack frame
				push	ebx				; save registers
				push	ecx
				push	edx
				pushf

				mov		eax,[ebp+8]		;copy the first parameter to eax
				mov		number_1, eax
				mov		eax,[ebp+12]	;copy the second parameter to eax
				mov		number_2, eax
				mov		eax,[ebp+16]
				mov		number_3, eax

				cmp		eax, number_2		;compare num3 and num2
				jg		Larger			;jump if num3 is greater than num2
				jl		Smaller			;jump if num3 is smaller than num2

Larger:			cmp		eax, number_1	;copy num1 to eax
				jg		finish
				jl		Smaller1				

Smaller1:		mov		eax, number_1
				jmp		finish

Smaller:		mov		eax, number_2
				cmp		eax, number_1
				jg		finish
				jl		Smaller1
finalLarge:		
finish:			popf
				pop		edx
				pop		ecx
				pop		ebx
				pop		ebp
				ret		
Max3 ENDP

Avg PROC
			push	ebp
			mov		ebp, esp
			pushad
			pushf

			mov		ebx, [ebp+8]
			mov		eax, [ebp+12]
			mov		nbrInts, eax
			mov		ecx, 0
			mov		eax, 0
			
			moreEle:	add eax, [ebx]	
					add ebx, 4
					inc ecx
					cmp	ecx, nbrInts
					jle moreEle
			add		eax, 5
			cdq
			mov		ebx, nbrInts
			idiv	ebx
			mov		ebx, [ebp+16]
			mov		[ebx], eax

			popf
			popad
			pop	ebp
			ret
Avg ENDP

Search PROC
			push	ebp
			mov		ebp, esp
			push ebx
			push ecx
			push edx
			pushf

			mov		ebx, [ebp+8]	; load address of array
			mov		eax, [ebp+12]
			mov		nbrInts, eax
			mov		eax, [ebp+16]
			mov		count, 1

			searchProc:	
			mov		ecx, count		; 
			cmp		ecx, nbrInts	; compare count to number of elements
			jg		emptyArr		; jump if count > numElements
	
	loopForever:	
			cmp		ecx, nbrInts	; compare count and numElements
			jng		notIn			; jump if count < nbrElements
			output	mess, blank		; else display value not in array
			mov		eax, 0			; set index as 0
			jmp		endSearch		; then jump to ask user if they want to run again
	notIn:
			cmp		[ebx], eax		; compare current array element to search value
			jnz		noMatch			; jump if currElement != searchValue
			jmp		matched			; jump to prompt user
	noMatch:
			inc	ecx			; increment count
			add	ebx, 4		; increment to next array location
			jmp loopForever	; jump back to loop


matched:	mov eax, ecx
			jmp	endSearch

emptyArr:	output	mess2, blank		; notify user array is empty
endSearch:									
			popf
			pop edx
			pop ecx
			pop ebx
			pop	ebp
			ret
Search ENDP
END

