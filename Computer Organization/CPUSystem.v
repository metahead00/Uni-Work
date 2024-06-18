`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU COMPUTER ENGINEERING DEPARTMENT
// Engineer: MELIKE BESPARMAK - RACHA BADREDDINE
// 
// Date : 04/05/2024
// Module Name: CPU
// Project Name: COMPUTER ORGANIZATION PROJECT-2
//////////////////////////////////////////////////////////////////////////////////


module CPUSystem (
    input wire Clock,
    input wire Reset,
    output reg[7:0] T
); 
    // ADDRESS REGISTER FILE
    reg [1:0] ARF_OutCSel;  // Address Register File Output C Selector
    reg [1:0] ARF_OutDSel;  // Address Register File Output D Selector
    reg [2:0] ARF_FunSel;   // Address Register File Function Selector
    reg [2:0] ARF_RegSel;   // Address Register File Register Selector

    // REGISTER FILE
    reg [2:0] RF_OutASel;   // Register File Output A Selector 
    reg [2:0] RF_OutBSel;   // Register File Output B Selector 
    reg [2:0] RF_FunSel;    // Register File Function Selector 
    reg [3:0] RF_RegSel;    // Register File General Purpose Register Selector 
    reg [3:0] RF_ScrSel;
    
    // ALU 
    reg [4:0] ALU_FunSel;   // Arithmetic Logic Unit Function Selector
    reg ALU_WF;             // Arithmetic Logic Unit Write Flag   // Register File Scratch Register Selector
    
    // INSTRUCTION REGISTER
    reg IR_LH;              // Instruction Register Low/High Bit Selector
    reg IR_Write;           // Instruction Register Write Flag
    
    // MEMORY 
    reg Mem_WR;            
    reg Mem_CS;
    
    // MUX A/B/C
    reg [1:0] MuxASel;      // Multiplexer A Selector
    reg [1:0] MuxBSel;      // Multiplexer B Selector
    reg MuxCSel;            // Multiplexer C Selector
    
    ArithmeticLogicUnitSystem _ALUSystem(.RF_OutASel(RF_OutASel), .RF_OutBSel(RF_OutBSel), .RF_FunSel(RF_FunSel), .RF_RegSel(RF_RegSel), .RF_ScrSel(RF_ScrSel), .ALU_FunSel(ALU_FunSel), .ALU_WF(ALU_WF), .ARF_OutCSel(ARF_OutCSel), .ARF_OutDSel(ARF_OutDSel), .ARF_FunSel(ARF_FunSel), .ARF_RegSel(ARF_RegSel), .IR_LH(IR_LH) , .IR_Write(IR_Write), .Mem_WR(Mem_WR) , .Mem_CS(Mem_CS) , .MuxASel(MuxASel), .MuxBSel(MuxBSel), .MuxCSel(MuxCSel), .Clock(Clock));
    
    reg SC_Reset;

    initial begin
        T = 0; 
        ARF_RegSel = 3'b111;
        RF_RegSel = 4'b1111;
        RF_ScrSel = 4'b1111;
        _ALUSystem.ARF.SP.Q = 16'h00ff;
        _ALUSystem.ARF.PC.Q = 16'h0000;
        _ALUSystem.ARF.AR.Q = 16'h0000;
        _ALUSystem.RF.R1.Q = 16'h0000;
        _ALUSystem.RF.R2.Q = 16'h0000;
        _ALUSystem.RF.R3.Q = 16'h0000;
        _ALUSystem.RF.R4.Q = 16'h0000;
        _ALUSystem.RF.S1.Q = 16'h0000;
        _ALUSystem.RF.S2.Q = 16'h0000;
        _ALUSystem.RF.S3.Q = 16'h0000;
        _ALUSystem.RF.S4.Q = 16'h0000;
        _ALUSystem.ALU.ALUOut = 16'h0000;
        ALU_WF = 1'b0;
        SC_Reset = 1'b0; 
    end
    
    reg[15:0] IR;   
    reg[5:0] opcode;
    reg Z;
    
    reg[1:0] RSEL;

    
    reg [2:0] t = 0;
    
    // Sequence Counter
    // t => 000 -> 001 -> 010 -> 011...
    // T =>  0  ->  1  ->  2  ->  3...  (8 bits)
    always @(posedge Clock) begin
        if(SC_Reset == 1) begin
            T[t - 1]= 0;            //Zero out the previous bit
            t = 0;
            T[t]= 1;
            t <= t + 1;
            SC_Reset = 0; //disable Reset
        end
        else  begin
            if(t >= 1) T[t - 1]= 0; //Zero out the previous bit
            T[t]= 1;
            t <= t + 1;
        end
    end
      
    always@(posedge T[0])
        begin
            //Disable all
            RF_RegSel = 4'b1111;
            RF_ScrSel = 4'b1111;
         
            ARF_OutDSel = 2'b00;
            Mem_WR = 1'b0;
            Mem_CS = 1'b0;
            IR_Write = 1'b1;
            IR_LH = 1'b0;
            
            ARF_RegSel = 3'b011; //To enable PC
            ARF_FunSel = 3'b001; //Increment PC
            
            //To start fetching decoding and executing next instruction
            //SC_Reset = 1'b0;
        end
             
    always@(posedge T[1])
        begin
            ARF_OutDSel = 2'b00;
            Mem_WR = 1'b0;
            Mem_CS = 1'b0;
            IR_Write = 1'b1;
            IR_LH = 1'b1;

            ARF_RegSel = 3'b011; //To enable PC
            ARF_FunSel = 3'b001; //Increment PC
        end
                
    always@(posedge T[2])
        begin
        //Since MSB of IR were ne accessed we use the memout since it is storing the MSB of IR after fetching
            opcode = _ALUSystem.MemOut[7:2];
            RSEL = _ALUSystem.MemOut[1:0];
            
            //Here we assigned because we need to get all changes 
            assign IR = _ALUSystem.IR.IROut;
            assign Z = _ALUSystem.ALU.FlagsOut[3];
            case(opcode)
                6'h00: //BRA
                begin               
                    ARF_RegSel = 3'b111;
                    Mem_CS = 1'b1;
                    IR_Write = 1'b0;
                    
                    MuxASel = 2'b11;    // IR Out
                    RF_ScrSel = 4'b0111;
                    RF_FunSel = 3'b010;                    
                end

                6'h01: //BNE
                begin
                    if(Z == 0)
                    begin
                        ARF_RegSel = 3'b111;
                        Mem_CS = 1'b1;
                        IR_Write = 1'b0;
                        
                        MuxASel = 2'b11;
                        RF_ScrSel = 4'b0111;
                        RF_FunSel = 3'b010;
                    end
                    else
                        SC_Reset = 1;
                end

                6'h02: //BEQ
                begin
                    if(Z == 1)
                        begin
                        
                            ARF_RegSel = 3'b111;
                            Mem_CS = 1'b1;
                            IR_Write = 1'b0;
                            
                            MuxASel = 2'b11;
                            RF_ScrSel = 4'b0111;
                            RF_FunSel = 3'b010;
                        end
                    else
                        SC_Reset = 1; 
                end

                6'h03: //POP
                begin
                    ARF_RegSel = 3'b110;
                    ARF_FunSel = 3'b001; // sp <- sp + 1                  
                end

                6'h04: //PSH
                begin
                    // Write LSB to memory
                    ARF_OutDSel = 2'b11;
                    Mem_CS = 1'b0;
                    Mem_WR = 1'b1;
                    
                    RF_OutASel = {1'b0,RSEL};
                    ALU_FunSel = 5'b10000;
                    MuxCSel = 1'b0; // WRITE LSB FIRST
                    ALU_WF = 0; // CHECK
                    
                    //Decrement SP
                    ARF_RegSel = 3'b110;
                    ARF_FunSel = 3'b000;
                end
                        
                //IND AND DEC ONE GROUP
                6'h05, 6'h06:
                begin
                    //SHOULD WE ASSIGN S
                    ALU_WF = RSEL[1]; //S is the most significant bit og RSEL
                    
                    //OUTPUT AND MUX CHOICE FOR SOURCE
                    if(IR[5] == 1'b0) //SOURCE IS ARF
                    begin
                        case(IR[4:3])
                            // SOURCE REG 1
                            2'b00: ARF_OutCSel = 2'b00;
                            2'b01: ARF_OutCSel = 2'b00;
                            2'b10: ARF_OutCSel = 2'b11;
                            2'b11: ARF_OutCSel = 2'b10;
                        endcase
                        
                        //CHOOSE MUX 
                        if(RSEL[0] == 0) MuxBSel = 2'b01; //IF ARF IS DESTINATION 
                        else MuxASel = 2'b01;
                    end
                    else if(IR[5] == 1'b1)
                    begin
                        case(IR[4:3])
                            2'b00: RF_OutASel = 3'b000;
                            2'b01: RF_OutASel = 3'b001;
                            2'b10: RF_OutASel = 3'b010;
                            2'b11: RF_OutASel = 3'b011;
                        endcase
                        
                        ALU_FunSel = 5'b10000;
                        
                        if(RSEL[0] == 0) MuxBSel = 2'b00;
                        else MuxASel = 2'b00;
                    end
                    
                    //Enabling DSTREG
                    if(RSEL[0] == 1'b0) //LSB of RSEL is MSB of DSTREG
                    begin
                        case(IR[7:6])
                            2'b00: ARF_RegSel = 3'b011;
                            2'b01: ARF_RegSel = 3'b011;
                            2'b10: ARF_RegSel = 3'b110;
                            2'b11: ARF_RegSel = 3'b101;
                        endcase
                        
                        ARF_FunSel = 3'b010;
                    end
                    else
                    begin
                        //disable here for all cases?
                        ARF_RegSel = 3'b111;
                        Mem_CS = 1'b1;
                        IR_Write = 1'b0;
                        
                        case(IR[7:6])
                            2'b00: RF_RegSel = 4'b0111;
                            2'b01: RF_RegSel = 4'b1011;
                            2'b10: RF_RegSel = 4'b1101;
                            2'b11: RF_RegSel = 4'b1110;
                        endcase
                        
                        RF_FunSel = 3'b010;
                    end                                                                                                                                                            
                end

                6'h07, 6'h08, 6'h09, 6'h0A, 6'h0B, 6'h0C, 6'h0D, 6'h0E, 6'h0F, 6'h10, 6'h15, 6'h16, 6'h17, 6'h18, 6'h19, 6'h1A, 6'h1B, 6'h1C, 6'h1D: //DSTREG <-  SREG1
                begin
                    //IN T2 S1 <- SREG1 if it is in ARF
                    if(IR[5] == 1'b0) //SOURCE IS ARF
                        begin
                            case(IR[4:3])
                                // SOURCE REG 1
                                2'b00: ARF_OutCSel = 2'b00;
                                2'b01: ARF_OutCSel = 2'b00;
                                2'b10: ARF_OutCSel = 2'b11;
                                2'b11: ARF_OutCSel = 2'b10;
                            endcase
                            
                            MuxASel = 2'b01;
                            RF_ScrSel = 4'b0111; //S1
                            RF_FunSel = 3'b010;  //LOAD
                        end
                        
                        ARF_RegSel = 3'b111;
                        Mem_CS = 1'b1;
                        IR_Write = 1'b0;
                end
                                
                6'h11: //MOVH
                begin
                    MuxASel = 2'b11;
                    RF_FunSel = 3'b110;
                    
                    case(RSEL) //RSEL
                        2'b00: RF_RegSel = 4'b0111;
                        2'b01: RF_RegSel = 4'b1011;
                        2'b10: RF_RegSel = 4'b1101;
                        2'b11: RF_RegSel = 4'b1110;
                    endcase
                    
                    ARF_RegSel = 3'b111;
                    Mem_CS = 1'b1;
                    IR_Write = 1'b0;
                    
                    SC_Reset = 1;
                end

                6'h12: // LDR, for lsb
                begin
                    ARF_OutDSel = 2'b10;
                    Mem_CS = 0;
                    Mem_WR = 0;                              
                    MuxASel = 2'b10;
                    RF_FunSel = 3'b101;
                    
                    case(RSEL) //RSEL
                        2'b00: RF_RegSel = 4'b0111;
                        2'b01: RF_RegSel = 4'b1011;
                        2'b10: RF_RegSel = 4'b1101;
                        2'b11: RF_RegSel = 4'b1110;
                    endcase
                    
                    ARF_FunSel = 3'b001;
                    ARF_RegSel = 3'b101;
                end

                6'h13: // STR, lsb first 
                begin
                    RF_OutASel = {1'b0,RSEL};
                    ALU_FunSel = 5'b10000;
                    ALU_WF = 0;
                    MuxCSel = 0;
                    ARF_OutDSel = 2'b10;
                    Mem_CS = 0;
                    Mem_WR = 1;
                    
                    // Increment AR
                    ARF_RegSel = 3'b101;
                    ARF_FunSel = 3'b001;
                end

                6'h14: // MOVL
                begin
                    MuxASel = 2'b11;
                    RF_FunSel = 3'b101;
                    
                    case(RSEL) //RSEL
                        2'b00: RF_RegSel = 4'b0111;
                        2'b01: RF_RegSel = 4'b1011;
                        2'b10: RF_RegSel = 4'b1101;
                        2'b11: RF_RegSel = 4'b1110;
                    endcase
                    
                    ARF_RegSel = 3'b111;
                    Mem_CS = 1'b1;
                    IR_Write = 1'b0;
                    
                    SC_Reset = 1;
                end  
                                                        
                6'h1E: // BX, similar to push
                begin
                    // S1 <- PC
                    ARF_OutCSel = 2'b00;
                    MuxASel = 2'b01;
                    RF_ScrSel = 4'b0111;
                    RF_FunSel = 3'b010;
                    
                    // PC <- Rx
                    RF_OutASel = {1'b0,RSEL};
                    ALU_FunSel = 5'b10000;
                    ALU_WF = 0;
                    MuxBSel = 2'b00;
                    ARF_RegSel = 3'b011;
                    ARF_FunSel = 3'b010;                                 
                end 
                    
                6'h1F: // BL, similar to pop
                begin
                    ARF_RegSel = 3'b110;
                    ARF_FunSel = 3'b001; // sp <- sp + 1  
                end 
                                                                
                6'h20: // LDRIM
                begin
                    // AR <- VALUE
                    MuxBSel = 2'b11;
                    ARF_RegSel = 3'b101;
                    ARF_FunSel = 3'b010;                             
                end
                
                6'h21: // STRIM
                begin
                    // S1 <- AR
                    ARF_OutCSel = 2'b10;
                    MuxASel = 2'b01;
                    RF_ScrSel = 4'b0111;
                    RF_FunSel = 3'b010;
                    
                    // AR <- OFFSET
                    MuxBSel = 2'b11;
                    ARF_RegSel = 3'b101;
                    ARF_FunSel = 3'b010; // msb always 00                             
                end
            endcase
        end
        
    always@(posedge T[3])
        begin
            case(opcode)
                6'h00, 6'h01, 6'h02: // control with ifs if doesnt work
                begin
                    ARF_RegSel = 3'b111;
                    MuxASel <= 2'b01;
                    RF_ScrSel <= 4'b1011;
                    
                    RF_FunSel <= 3'b010;
                    ARF_OutCSel <= 2'b00;
                end 

                6'h03: //POP
                begin
                    Mem_CS = 1'b0;
                    Mem_WR = 1'b0;
                    ARF_OutDSel = 2'b11;
                    MuxASel = 2'b10;
                    RF_FunSel = 3'b110;  // POP MSB first
                    
                    case(RSEL) //RSEL
                        2'b00: RF_RegSel = 4'b0111;
                        2'b01: RF_RegSel = 4'b1011;
                        2'b10: RF_RegSel = 4'b1101;
                        2'b11: RF_RegSel = 4'b1110;
                    endcase
                    
                    
                    ARF_RegSel = 3'b110; // Increment SP
                    ARF_FunSel = 3'b001;
                    
                    case(RSEL) //RSEL
                        2'b00: RF_RegSel = 4'b0111;
                        2'b01: RF_RegSel = 4'b1011;
                        2'b10: RF_RegSel = 4'b1101;
                        2'b11: RF_RegSel = 4'b1110;
                    endcase
                end

                6'h04: //PSH
                begin
                    // Write MSB to memory
                    ARF_OutDSel = 2'b11;
                    Mem_CS = 1'b0;
                    Mem_WR = 1'b1;
                    
                    RF_OutASel = {1'b0,RSEL};
                    ALU_FunSel = 5'b10000;
                    MuxCSel = 1'b1; // WRITE MSB 
                    ALU_WF = 0; // CHECK
                    
                    //Decrement SP
                    ARF_RegSel = 3'b110;
                    ARF_FunSel = 3'b000;
                    
                    //SC <- 0
                    SC_Reset = 1; 
                end
        
                6'h05, 6'h06: //IND , DEC
                begin                                                                                     
                    //INREMENT OR DECREMENT
                    if(opcode == 6'h05) RF_FunSel = 3'b001;
                    else if(opcode == 6'h06) RF_FunSel = 3'b000;
                    
                    //RESET
                    SC_Reset = 1;
                end
                                    
                6'h07, 6'h08, 6'h09, 6'h0A, 6'h0B, 6'h0E, 6'h18: //DSTREG <- ALUFUN (Rx or S1)
                begin
                    //SHOULD WE ASSIGN S
                    ALU_WF = 0;
                    //SOURCE IS ARF then S1
                    if(IR[5] == 1'b0) RF_OutASel = 3'b100;
                    else if(IR[5] == 1'b1) //Source is in Rx
                        begin
                            RF_OutASel = {1'b0,IR[4:3]};
                        end
                    
                    //ACCORDING TO OPCODE WE CHOOSE THE OPERATION
                    if(opcode == 6'h07) ALU_FunSel = 5'b11011; //LSL
                    else if(opcode == 6'h08) ALU_FunSel = 5'b11100; //LSR
                    else if(opcode == 6'h09) ALU_FunSel = 5'b11101; //ASR
                    else if(opcode == 6'h0A) ALU_FunSel = 5'b11110; //CSL
                    else if(opcode == 6'h0B) ALU_FunSel = 5'b11111; //CSR
                    else if(opcode == 6'h0E) ALU_FunSel = 5'b10010; //NOT
                    else if(opcode == 6'h18) ALU_FunSel = 5'b10000; //MOVS
                        
                    //ENABLE DTREG TO LOAD
                    //Enabling DSTREG
                    if(RSEL[0] == 1'b0) //LSB of RSEL is MSB of DSTREG
                    begin
                        case(IR[7:6])
                            2'b00: ARF_RegSel = 3'b011;
                            2'b01: ARF_RegSel = 3'b011;
                            2'b10: ARF_RegSel = 3'b110;
                            2'b11: ARF_RegSel = 3'b101;
                        endcase
                        
                        MuxBSel = 2'b00;
                        ARF_FunSel = 3'b010;
                    end
                    else
                    begin
                        case(IR[7:6])
                            2'b00: RF_RegSel = 4'b0111;
                            2'b01: RF_RegSel = 4'b1011;
                            2'b10: RF_RegSel = 4'b1101;
                            2'b11: RF_RegSel = 4'b1110;
                        endcase
                        
                        MuxASel = 2'b00;
                        RF_FunSel = 3'b010;
                    end 
                            
                    //RESET
                    SC_Reset = 1;
                end
                                                        
                6'h0C, 6'h0D, 6'h0F, 6'h10, 6'h15, 6'h16, 6'h17, 6'h19, 6'h1A, 6'h1B, 6'h1C, 6'h1D: //DSTREG <-  SREG2
                begin
                    //IN T3 S2 <- SREG2 if it is in ARF
                    if(IR[2] == 1'b0) //SOURCE IS ARF
                    begin
                        case(IR[1:0])
                            // SOURCE REG 2
                            2'b00: ARF_OutCSel = 2'b00;
                            2'b01: ARF_OutCSel = 2'b00;
                            2'b10: ARF_OutCSel = 2'b11;
                            2'b11: ARF_OutCSel = 2'b10;
                        endcase
                        
                        MuxASel = 2'b01;
                        RF_ScrSel = 4'b1011; //S2
                        RF_FunSel = 3'b010;  //LOAD
                    end
                end
                
                6'h12: // LDR, for msb
                begin
                    ARF_OutDSel = 2'b10;
                    Mem_CS = 0;
                    Mem_WR = 0;                              
                    MuxASel = 2'b10;
                    RF_FunSel = 3'b110;
                    
                    case(RSEL) //RSEL
                        2'b00: RF_RegSel = 4'b0111;
                        2'b01: RF_RegSel = 4'b1011;
                        2'b10: RF_RegSel = 4'b1101;
                        2'b11: RF_RegSel = 4'b1110;
                    endcase
                    
                    SC_Reset = 1;
                end

                6'h13: // STR, msb second
                begin
                    RF_OutASel = {1'b0,RSEL};
                    ALU_FunSel = 5'b10000;
                    ALU_WF = 0;
                    MuxCSel = 1;
                    ARF_OutDSel = 2'b10;
                    Mem_CS = 0;
                    Mem_WR = 1;
                    
                    SC_Reset = 1;
                end  

                6'h1E: // BX
                begin
                    // Write lsb to mem
                    Mem_WR = 1;
                    Mem_CS = 0;                            
                    ARF_OutDSel = 2'b11; 
                    
                    RF_OutASel = 3'b100;
                    ALU_FunSel = 5'b10000;
                    ALU_WF = 0;
                    MuxCSel = 0;
                    
                    // push op -> decrement sp
                    ARF_RegSel = 3'b110;
                    ARF_FunSel = 3'b000;                                
                end      
                                
                6'h1F: // BL
                begin
                    Mem_CS = 1'b0;
                    Mem_WR = 1'b0;
                    ARF_OutDSel = 2'b11;
                    MuxBSel = 2'b10;
                    
                    // MSB PC <- M[SP] 
                    ARF_RegSel = 3'b011; 
                    ARF_FunSel = 3'b110;     
                end
                    
                6'h20: // LDRIM
                begin
                    ARF_OutDSel = 2'b10;
                    Mem_CS = 0;
                    Mem_WR= 0;
                    
                    MuxASel = 2'b10;
                    RF_FunSel = 3'b101; //Load Low
                    
                    case(RSEL) //RSEL
                        2'b00: RF_RegSel = 4'b0111;
                        2'b01: RF_RegSel = 4'b1011;
                        2'b10: RF_RegSel = 4'b1101;
                        2'b11: RF_RegSel = 4'b1110;
                    endcase
                    
                    //SC_Reset = 1;
                    //Since word 16-bit we need to load 16 bits
                    
                    ARF_RegSel = 3'b101;
                    ARF_FunSel = 3'b001;
                end
                    
                6'h21: // STRIM
                begin
                    // S2 <- M[AR] (OFFSET)
                    ARF_OutDSel = 2'b10;
                    Mem_CS = 0;
                    Mem_WR = 0;
                    
                    MuxASel = 2'b10;
                    RF_ScrSel = 4'b1011;
                    RF_FunSel = 3'b010;
                end
        endcase
        end
            
    always@(posedge T[4])
        begin
            case(opcode)
                6'h00, 6'h01, 6'h02: 
                begin
                    MuxBSel = 2'b00;
                    ARF_FunSel = 3'b010;
                    ARF_RegSel = 3'b011;
                    ALU_FunSel = 5'b10100;
                    RF_OutASel = 3'b100;
                    RF_OutBSel = 3'b101; 
                    
                    SC_Reset = 1;                                 
                end  

                6'h03: //POP
                begin
                    Mem_CS = 1'b0;
                    Mem_WR = 1'b0;
                    ARF_OutDSel = 2'b11;
                    MuxASel = 2'b10;
                    RF_FunSel = 3'b101;  // POP LSB in t4   
                    
                    ARF_RegSel = 3'b111;    
                    
                    case(RSEL) //RSEL
                        2'b00: RF_RegSel = 4'b0111;
                        2'b01: RF_RegSel = 4'b1011;
                        2'b10: RF_RegSel = 4'b1101;
                        2'b11: RF_RegSel = 4'b1110;
                    endcase
                    
                    //RESET
                    SC_Reset = 1;
                end  
                // push op is done at t3
                            
                6'h0C, 6'h0D, 6'h0F, 6'h10, 6'h15, 6'h16, 6'h17, 6'h19, 6'h1A, 6'h1B, 6'h1C, 6'h1D: //DSTREG <-  SREG2
                begin
                    ALU_WF = RSEL[1];
                                                    
                    if(IR[5] == 1'b0) RF_OutASel = 3'b100;              //Source 1 is in ARF then S1
                    else if(IR[5] == 1'b1) RF_OutASel = {1'b0,IR[4:3]}; //Source is in Rx
                                                
                    if(IR[2] == 1'b0) RF_OutBSel = 3'b101;              //Source 2 is in ARF then S2
                    else if(IR[2] == 1'b1) RF_OutBSel = {1'b0,IR[1:0]}; //Source is in Rx
                    
                    if(opcode == 6'h0C || opcode == 6'h1B)      ALU_FunSel = 5'b10111; // AND - ANDS
                    else if(opcode == 6'h0D || opcode == 6'h1C) ALU_FunSel = 5'b11000; // OR - ORS
                    else if(opcode == 6'h0F || opcode == 6'h1D) ALU_FunSel = 5'b11001; // XOR - XORS
                    else if(opcode == 6'h17 || opcode == 6'h1A) ALU_FunSel = 5'b10110; // SUB - SUBS 
                    else if(opcode == 6'h15 || opcode == 6'h19) ALU_FunSel = 5'b10100; // ADD - ADDS
                    else if(opcode == 6'h10)                    ALU_FunSel = 5'b11010; // NAND
                    else if(opcode == 6'h16)                    ALU_FunSel = 5'b10101; // ADD + Carry
                                    
                                    
                    //Enabling DSTREG
                    if(RSEL[0] == 1'b0) //LSB of RSEL is MSB of DSTREG
                        begin
                        case(IR[7:6])
                            2'b00: ARF_RegSel = 3'b011;
                            2'b01: ARF_RegSel = 3'b011;
                            2'b10: ARF_RegSel = 3'b110;
                            2'b11: ARF_RegSel = 3'b101;
                        endcase
                        
                        MuxBSel = 2'b00;
                        ARF_FunSel = 3'b010;
                        end
                    else
                        begin
                        case(IR[7:6])
                            2'b00: RF_RegSel = 4'b0111;
                            2'b01: RF_RegSel = 4'b1011;
                            2'b10: RF_RegSel = 4'b1101;
                            2'b11: RF_RegSel = 4'b1110;
                        endcase
                        
                        MuxASel = 2'b00;
                        RF_FunSel = 3'b010;
                        end 
                                            
                    //RESET
                    SC_Reset = 1;                         
                end
                            
                6'h1E: // BX
                begin
                    // Write msb to mem
                    Mem_WR = 1;
                    Mem_CS = 0;                            
                    ARF_OutDSel = 2'b11; 
                    
                    RF_OutASel = 3'b100;
                    ALU_FunSel = 5'b10000;
                    ALU_WF = 0;
                    MuxCSel = 1;
                    
                    //Decrement SP
                    ARF_RegSel = 3'b110;
                    ARF_FunSel = 3'b000;
                    
                    SC_Reset = 1;
                end         

                6'h1F: // BL
                begin
                    ARF_RegSel = 3'b110;
                    ARF_FunSel = 3'b001; // sp <- sp + 1  
                end
                                
                6'h21: // STRIM
                begin
                    // AR <- S1 + S2 (AR + OFFSET)
                    RF_OutASel = 3'b100;
                    RF_OutBSel = 3'b101;
                    
                    ALU_FunSel = 5'b10100; // a + b
                    ALU_WF = 0;
                    
                    MuxBSel = 2'b00;
                    ARF_RegSel = 3'b101;
                    ARF_FunSel = 3'b010;
                end
                                
                6'h20: // LDRIM
                begin
                    ARF_OutDSel = 2'b10;
                    Mem_CS = 0;
                    Mem_WR= 0;
                    
                    MuxASel = 2'b10;
                    RF_FunSel = 3'b110; //Load Low
                    
                    case(RSEL) //RSEL
                        2'b00: RF_RegSel = 4'b0111;
                        2'b01: RF_RegSel = 4'b1011;
                        2'b10: RF_RegSel = 4'b1101;
                        2'b11: RF_RegSel = 4'b1110;
                    endcase
                    
                    //disable all
                    ARF_RegSel = 3'b111;
                    
                    //Reset
                    SC_Reset = 1;                          
                end
            endcase
        end

    always@(posedge T[5])
        begin
            case(opcode)
                6'h1F: // BL
                begin
                    Mem_CS = 1'b0;
                    Mem_WR = 1'b0;
                    ARF_OutDSel = 2'b11;
                    MuxBSel = 2'b10;
                    
                    // MSB PC <- M[SP] 
                    ARF_RegSel = 3'b011; 
                    ARF_FunSel = 3'b101;
                    
                    SC_Reset = 1; 
                end
                                
                6'h21: // STRIM
                begin
                    // M[AR] <- Rx (lsb)
                    RF_OutASel = {1'b0,RSEL};
                    ALU_FunSel = 5'b10000;
                    ALU_WF = 0;
                    MuxCSel = 0;
                    ARF_OutDSel = 2'b10;
                    Mem_CS = 0;
                    Mem_WR = 1;
                    
                    // Increment AR
                    ARF_RegSel = 3'b101;
                    ARF_FunSel = 3'b001;
                end
            endcase
        end
                    
    always@(posedge T[6])
        begin
            case(opcode)
                6'h21: // STRIM
                begin
                    // M[AR] <- Rx (msb)
                    RF_OutASel = {1'b0,RSEL};
                    ALU_FunSel = 5'b10000;
                    ALU_WF = 0;
                    MuxCSel = 1;
                    ARF_OutDSel = 2'b10;
                    Mem_CS = 0;
                    Mem_WR = 1;
                            
                    SC_Reset = 1;                     
                end
            endcase
        end

endmodule