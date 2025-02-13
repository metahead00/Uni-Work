; Melike Besparmak
; 150220061

        AREA rec, CODE, READONLY
        ENTRY
        THUMB
        ALIGN

__main  FUNCTION
        EXPORT __main            ; Export the __main function
        MOVS R0, #0              ; Initialize return value
        LDR R1, =profit_array    ; R1 <- profit array
        LDR R2, =weight_array    ; R2 <- weight array
        MOVS R3, #50             ; Capacity (w)
        MOVS R4, #3              ; Number of items (n)
        BL knapsack              ; Branch to knapsack function
        B stop                   ; End program

knapsack
        PUSH {LR}                ; Save return address
        CMP R3, #0               ; If capacity == 0
        BEQ return0              ; Return 0
        CMP R4, #0               ; If items == 0
        BEQ return0              ; Return 0

        ; Recursive call for f(w, n-1)
        PUSH {R3, R4}            ; Save current capacity and item count
        SUBS R4, R4, #1          ; n = n-1
        BL knapsack              ; knapsack(w, n-1)
        MOVS R7, R0              ; Store result of f(w, n-1) in R7
        POP {R3, R4}             ; Restore capacity and item count

        ; Check if weight[n-1] > capacity
        SUBS R5, R4, #1          ; n-1
        LSLS R5, R5, #2          ; Offset for weight array
        LDR R5, [R2, R5]         ; weight[n-1]
        CMP R5, R3               ; Compare weight with capacity
        BGT store_result         ; Skip inclusion if weight > capacity

        ; Calculate profit[n-1] + f(w - weight[n-1], n-1)
        PUSH {R3, R4}            ; Save current capacity and item count
		SUBS R4, R4, #1			 ; n=n-1	
        SUBS R3, R3, R5          ; w = w - weight[n-1]
        BL knapsack              ; knapsack(w-weight[n-1], n-1)
		POP {R3, R4}             ; Restore capacity and item count
		SUBS R6, R4, #1			 ; n-1
        LSLS R6, #2          	 ; Offset for profit array
        LDR R6, [R1, R6]         ; profit[n-1]
        ADDS R0, R0, R6          ; profit[n-1] + f(w-weight[n-1], n-1)

        ; Compare results and update R0
        CMP R0, R7               ; Compare inclusion and exclusion
        BLE store_result         ; If exclusion is greater, skip
		MOV R7, R0               ; Otherwise, update R7

store_result
        MOV R0, R7               ; Set R0 to the maximum result
        POP {PC}                 ; Return

return0
        MOVS R0, #0              ; Return 0
        POP {PC}                 ; Return

stop
        B stop                   ; Infinite loop to end program
		ALIGN
		ENDFUNC
profit_array DCD 60, 100, 120    ; Profit values
weight_array DCD 10, 20, 30      ; Weight values
        END
