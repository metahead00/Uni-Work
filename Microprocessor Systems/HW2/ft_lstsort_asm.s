; Function: ft_lstsort_asm
; Parameters:
;   R0 - Pointer to the list (address of t_list *)
;   R1 - Pointer to comparison function (address of int (*f_comp)(int, int))

	AREA    Sorting_Code, CODE, READONLY
	ALIGN
	THUMB
	EXPORT  ft_lstsort_asm

next    EQU     4			; for readability

ft_lstsort_asm FUNCTION
    PUSH    {R0-R1, LR}      ; Save registers and link register
    LDR     R3, [SP]         ; Load pointer to the head of the list (R0)
    LDR     R3, [R3]         ; HEAD
    LDR     R4, [SP, #4]     ; Load pointer to comparison function (R1)
    MOV     R5, R3           ; Current for outer loop

outer_loop
    CMP     R5, #0           ; Break if null
    BEQ     end
    MOVS    R2, #0           ; Set prev (previous) node 
    MOV     R6, R3           ; Current for inner loop

inner_loop
	CMP     R6, #0           ; Break if current is null
    BEQ     end_inner
    
	LDR     R7, [R6, #next]  ; Next node
	CMP     R7, #0           ; Break if next is null
    BEQ     end_inner
	
    PUSH    {R2-R3}			 ; Contents must be saved
    LDR     R0, [R6]         ; Current value
    LDR     R1, [R7]         ; Next value    
    BLX     R4               ; Go to compare function
    POP     {R2-R3}			 ; Recover
    CMP     R0, #1           ; Continue if no swap
    BEQ     continue

    ; Swap begins here
    ; R0 and R1 not important
    CMP     R2, #0			 ; if prev is null, it is head update 
    BEQ     head_swap
    STR     R7, [R2, #next]  ; prev->next = curr->next
    LDR     R0, [R7, #next]  ; curr->next->next = r0 
    STR     R0, [R6, #next]  ; curr->next = curr->next->next
    STR     R6, [R7, #next]  ; curr->next->next = curr
	B		continue

head_swap
    MOV     R3, R7           ; head = next
	LDR		R0, [R7, #next]	 ; r0 = next -> next
    STR     R6, [R7, #next]  ; Set R7->next = R6 (next->next = curr)
	STR		R0, [R6, #next]  ; set current->next = next->next
	B 		inner_loop
	
continue
    MOV     R2, R6           ; Set prev to current node
    LDR     R6, [R6, #next]  ; Update current to the next node
    B       inner_loop       ; Continue inner loop

end_inner
    LDR     R5, [R5, #4]     ; curr = curr->next for outer
    B       outer_loop       ; Continue with outer

end
    POP     {R0-R1, PC}      ; Restore registers and return
    ENDFUNC