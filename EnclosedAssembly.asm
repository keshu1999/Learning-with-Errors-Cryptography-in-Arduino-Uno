.dseg
	polynomial: .byte 512

.cseg
rcall START
/*R19 R18 * R17 R16*/
MA:
	MUL R18, R16
	MOVW R22, R0
	MUL R19, R17
	MOVW R24, R0
	MUL R18, R17
	ADD R23, R0
	ADC R24, R1
	MUL R19, R16
	ADD R23, R0
	ADC R24, R1
	RET

	//ASSUMING INITIAL RO IN REGISTERS R5:R2
SAMS2:
	MOV R9, R5
	MOV R8, R4
	MOV R7, R3
	MOV R6, R2
// T0->R11 R10 	T1->R13 R12 	T2->R15 R14
// 0X1E->R17 	0X01->R16
	MOV R12, R9
	MOV R11, R8
	MOV R10, R7
	LDI R27, 3 				// NUMBER OF TIMES WE NEED TO SHIFT
LABEL1:
	CLC
	ROL R10
	ROL R11
	ROL R12
	SUBI R27, 1
	BRNE LABEL1
	MOV R10, R11
	MOV R11, R12 			// T0

	MOV R13, R11
	MOV R12, R10
	LDI R27, 4
LABEL2:
	CLC
	ROR R13
	ROR R12
	SUBI R27, 1
	BRNE LABEL2 			// T1

	MOV R15, R13
	MOV R14, R12
	LDI R27, 4
LABEL3:
	CLC
	ROR R15
	ROR R14
	SUBI R27, 1
	BRNE LABEL3 			// T2

	ADD R14, R10
	ADC R15, R11
	ADD R14, R12
	ADC R15, R13
// SUM OF TO T1 T2 IN R15 R14

	LDI R16, 0x01
	LDI R17, 0x1e
	MOV R18, R14
	MOV R19, R15
	CALL MA
//PRODUCT IN R25 R24 R23 R22

	SUB R6, R22
	SBC R7, R23
	SBC R8, R24
	SBC R9, R25
// R - 0X1E01*[TO+T1+T2] -> R7 R6 (W0)

	MOV R21, R7
	MOV R20, R6 			// TEMPORARILY
	LDI R27, 3
LABEL4:
	CLC
	ROL R6
	ROL R7
	ROL R8
	SUBI R27, 1
	BRNE LABEL4
//R8 -> Q0 (W0>>13)
	LDI R16, 0x01
	LDI R17, 0x1e
	MOV R18, R8
	LDI R19, 0
	CALL MA
//PRODUCT IN R25 R24 R23 R22
	SUB R20, R22
	SBC R21, R23
// W0 - 0X1E01*Q0 -> R21 R20
	MOVW R24, R20

RET

//"div8u" - 8/8 Bit Unsigned Division
//This function is taken from AVR Application Notes AVR200.



BitReverse:
//Parameters
//1st The address of the array to be bit reversed
//2nd The number of elements in the array
//Y: Index
//Z: Reverse of index
//X: Stores the value in Y
//r4:r5 stores the value in Z
push r26
push r27
push r28
push r29
push r30
push r31
ldi r29, 0



ldi r31, 0

ldi r28, 0
steBeg:
cp r28, r22
cpc r29, r23
brlo ste1
jmp stePostEv

ste1:
ror r28
brcs CarSet1
rol r30
clc
jmp ste2
Carset1:
rol r30
sec

ste2:
ror r28
brcs CarSet2
rol r30
clc
jmp ste3
Carset2:
rol r30
sec

ste3:
ror r28
brcs CarSet3
rol r30
clc
jmp ste4
Carset3:
rol r30
sec

ste4:
ror r28
brcs CarSet4
rol r30
clc
jmp ste5

Carset4:
rol r30
sec

ste5:
ror r28
brcs CarSet5
rol r30
clc

jmp ste6
Carset5:
rol r30
sec

ste6:
ror r28
brcs CarSet6
rol r30
clc
jmp ste7

Carset6:
rol r30
sec

ste7:
ror r28
brcs CarSet7
rol r30
clc
jmp ste8

Carset7:
rol r30
sec

ste8:
ror r28
brcs CarSet8
rol r30
clc
jmp ste9

Carset8:
rol r30
sec

ste9:
ror r28

steEnd:
cp r30, r28
brlo steInc
breq steInc
//Generate addresses for information
clc
rol r28
rol r29
rol r30
rol r31
add r28, r24
add r29, r25
add r30, r24
add r31, r25
//Load values
ld r4, Y+
ld r5, Y
ld r26, Z+
ld r27, Z
//Store values
st Y, r27
st -Y, r26
st Z, r5
st -Z, r4
//Regenerate indices
sub r28, r24
sub r29, r25
sub r30, r24
sub r31, r25
clc
ror r29
ror r28
ror r31
ror r30

steInc:
adiw r28,1
jmp steBeg

stePostEv:
pop r31
pop r30
pop r29
pop r28
pop r27
pop r26
ret

Exp:
//Parameters
//r27 has the power to which to raise the value
//r26 has the result
//r18 has the modulus q
mul r26,r26
mov r26,r0
call div8u
mov r26,r16 							//Can be removed later
lsr r27
cpi r27, 1
brne Exp
ret

NTT:
//Parameters:
//1st An array base address 			R25 R24
//2nd n (some power of 2) 				R23 R22 (256)
//3nd An nth root of unity wn in Zq 	R21 R20 (198)
//4rd The modulus q 					R19 R18 (7681)
sub r2, r2
call BitReverse
movw r26, r24

movw r16, r22
add r16, r16
adc r17, r17
add r26, r16
adc r27, r17
st X+, r18
st X+, r19
st X+, r20
st X+, r21
st X+, r22
st X, r23
push r26
push r27

ldi r30,2
ldi r31,0
movw r4, r30 							//r5 r4 stores the value of i

LOOP1:
cp r22,r4
brne LOOP12
cp r23, r5
breq LOOP1END
LOOP12:
	mov r26, r20
	push r27
	call Exp 							//r27 r26 has wi
	pop r27
	ldi r16,1
	ldi r17,0 							//r17 r16 has w
	mov r14,r17
	mov r15,r17 						//r15 r14 has j
	movw r2, r4
	clc
	ror r3
	ror r2 //r3 r2 stores i/2
	
	LOOP2:
	cp r14, r2
	brne LOOP22
	cp r15, r3
	breq LOOP2END
	LOOP22:
		sub r6, r6
		sub r7, r7 						//r7 r6 stores the value of k. It is only used to check the functioning of the loop
			LOOP3:
			cp r6, r22
			brne LOOP33
			cp r7, r23
			breq LOOP3END

			LOOP33:
			movw r30, r24 				// Bass address copied
			movw r28, r6 				// k+j in r29 r28
			add r28, r14
			adc r29, r15
			add r30, r28
			adc r31, r29 				//Z (r31:r30) stores the address of the element to be retrieved

			ld r9, Z+
			ld r10, Z- 					//U-r10 r9
			add r30, r2

			adc r31, r3
			ld r11, Z+
			ld r12, Z- 					//V-r12 r11
			push r18
			push r19
			push r25
			push r24
			push r23
			push r22
			movw r18, r11
			call MA 					// V is stored in 12-11
										// Need register r25-r22 again
			mov r13, r9
			mov r14, r10
			sub r13, r11
			sbc r14, r12 				//U-V in r14:r13
			st Z+, r13
			st Z-, r14
			add r13, r11
			adc r14, r12
			add r13, r11
			adc r14, r12 				// U+V in r14:r13
			sub r30, r2
			sbc r31, r3 				//a[k+j] back in r31:r30
			st Z+, r13
			st Z-, r14
			add r6, r4
			adc r7, r5
			jmp LOOP3
		LOOP3END:
		mul r17, r26
		mov r17, r0
		jmp LOOP2
	LOOP2END:
	clc
	rol r5
	rol r4
	jmp LOOP1
LOOP1END:
RET


START:
	LDI r22,00
	ldi r23,01
	ldi r21,0x0D
	ldi r20,0x37
	ldi r19,0x1e
	ldi r18,01
	ldi r25, high(polynomial)
	ldi r24, low(polynomial)
	//Generating the polynomial array
	movw r26, r24
	ldi r16, 1
	ldi r17, 1
	beg1212:
		st x+, r16
		st x+, r2
		inc r16
		cpse r16, r17
		jmp beg1212
	st -x, r17 							//Polynomial array has been generated
	call NTT