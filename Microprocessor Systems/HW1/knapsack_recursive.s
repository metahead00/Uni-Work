; Melike Besparmak
; 150220061

; R0 <- value
; R1 <- profit array 
; R2 <- weight array 
; R3 <- capacity (w)
; R4 <- number of items (n)

create_array    EQU 0x32    ; Capacity is 50 

        AREA array, DATA, READWRITE
        ALIGN
        
dp_array        SPACE create_array
dp_array_end

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
        
stop    B stop                   ; Infinite loop to stop execution
        
        ALIGN
        ENDFUNC
        
knapsack  PUSH {LR, R3, R4, R5, R6, R7}  ; Save registers and LR
          CMP R3, #0                      ; If capacity (w) == 0
          BEQ return0                     ; Return 0
          CMP R4, #0                      ; If no items left (n == 0)
          BEQ return0                     ; Return 0

          SUB R4, R4, #1                  ; n = n - 1 for recursion

          ; Check if weight[n-1] > capacity
          LDR R5, [R2, R4, LSL #2]        ; R5 = weight[n-1]
          CMP R5, R3
          BGT skip_item                   ; Skip item if too heavy

          ; Include the item
          LDR R6, [R1, R4, LSL #2]        ; R6 = profit[n-1]
          SUB R3, R3, R5                  ; Reduce capacity: w = w - weight[n-1]
          BL knapsack                     ; Recurse with reduced capacity
          ADD R3, R3, R5                  ; Restore capacity
          ADD R6, R0, R6                  ; Add profit[n-1] to result

          ; Store the "include" result in R7
          MOV R7, R6                      ; R7 <- profit from including the item

skip_item BL knapsack                     ; Recurse without including item

          ; Compute max between "include" (R7) and "exclude" (R0)
          CMP R0, R7                      ; Compare R0 (exclude) and R7 (include)
          ITT GT                          ; If R0 > R7:
          MOVGT R0, R0                    ; R0 remains the max
          MOVLE R0, R7                    ; Otherwise, R0 = R7 (include is larger)

return0   POP {LR, R3, R4, R5, R6, R7}    ; Restore registers and LR
          BX LR                           ; Return to caller


profit_array DCD 60,100,120
profit_end    

weight_array DCD 10,20,30
weight_end

        END
