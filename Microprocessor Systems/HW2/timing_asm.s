		AREA    Timing_Code, CODE, READONLY
		ALIGN
		THUMB
		EXPORT  Systick_Start_asm
		EXPORT  Systick_Stop_asm
		EXPORT	SysTick_Handler 
			
		EXTERN	ticks
			
SysTick_LOAD    EQU 0xE000E014	;Address of load register
SysTick_VAL   	EQU 0xE000E018
SysTick_CTRL   	EQU 0xE000E010

SysTick_Handler FUNCTION
		PUSH	{LR}
		; You should only increment ticks here.
		LDR 	R0, =ticks	; Load the address of ticks
		LDR 	R1, [R0]	; Load the value of ticks
		ADDS	R1, #1		; Increment ticks
		STR		R1, [R0]	; Store the value of ticks
		POP		{PC}
		ENDFUNC


;The correct initialization sequence for the SysTick counter is:
;Program reload value.
;Clear current value.
;Program Control and Status register.


Systick_Start_asm FUNCTION
		PUSH	{LR}
		; You should initialize SysTick here.
		; Load addresses of SysTick registers
		LDR     R4, =SysTick_LOAD
		LDR     R5, =SysTick_VAL
		LDR     R6, =SysTick_CTRL

		; Program reload value, I calculated the value according to system_ARMCM0plus.asm file
		MOVS    R1, #249			; SystemClock = 250,000,000 -> reload = systemclock/100000 - 1 = 249
		STR     R1, [R4]			; Store it in correct address

		MOVS    R1, #0				; Clear current value
		STR     R1, [R5]			; Store it in correct address

		MOVS    R1, #0x07			; Program Control and Status register
		LDR		R2, [R6]			; 0x07 becaue enable, tickint and clock source bits must be 1
		ORRS	R1, R2				; Or because we dont want to change irrelevant bits but just set the necessary bits to 1
		STR     R1, [R6]			; Store it in correct address
		
		POP		{PC}
		ENDFUNC

Systick_Stop_asm FUNCTION
		PUSH	{LR}
		; You should stop SysTick, zero the ticks,
			; and return "non-zero value of ticks".
		LDR		R6, =SysTick_CTRL
		LDR		R2, [R6]			; Current value of control and status register
		
		MOVS	R3, #1				; Enable bit is lsb of control register
		MVNS	R3, R3				; Mask value for enable
		ANDS	R2, R3				; Just the lsb is set to zero, others are same
		STR		R2, [R6]			; Store the new value
		
		LDR 	R0, =ticks			; Load address of ticks
		LDR		R1, [R0]			; R1 stores the tick value before setting zero, aka elapsed
		MOVS	R6, #0				; Load 0 to clear
		STR		R6, [R0]			; Set tick to zero
		MOV		R0, R1				; R0 is the return register
		POP		{PC}
		ENDFUNC

		END
