`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU COMPUTER ENGINEERING DEPARTMENT
// Engineer: MELIKE BESPARMAK - RACHA BADREDDINE
// 
// Date : 04/04/2024
// Module Name: ArithmeticLogicUnitSystem
// Project Name: COMPUTER ORGANIZATION PROJECT-1
//////////////////////////////////////////////////////////////////////////////////

`include "Memory.v"
`include "InstructionRegister.v"
`include "ArithmeticLogicUnit.v"
`include "AddressRegisterFile.v"
`include "RegisterFile.v"

// 16-Bit-Output Multiplexer
module MUX_16(
    input wire [1:0] S,     // 2-Bit Selector     
    input wire [15:0] I_0,  // First Input : 16-Bit 
    input wire [15:0] I_1,  // Second Input : 16-Bit      
    input wire [7:0] I_2,   // Third Input : 8-Bit     
    input wire [7:0] I_3,   // Fourth Input : 8-Bit          
    output reg [15:0] out   // 16-Bit Output       
);
    always @(*) 
        begin
            // Output is selected by selector
            case(S)
                2'b00: out <= I_0;  
                2'b01: out <= I_1;
                2'b10: 
                    begin    
                        out[7:0] = I_2;
                        out[15:8] = 0;// 0 For memory
                    end
                2'b11: 
                    begin
                        out[7:0] = I_3;
                        out[15:8] = 0; 
                    end
            endcase
        end
endmodule


// 8-Bit-Output Multiplexer
module MUX_8(
    input wire S,         // 1-Bit Selector
    input wire [15:0] I,  // 16-Bit Input Data
    output reg [7:0] out  // 8-Bit Output (MSB 8 bits / LSB 8 bits)
);
    always @(*) 
        begin
            // Output is selected by selector
            case(S)
                1'b0: out = I[7:0];
                1'b1: out = I[15:8];             
            endcase
        end
endmodule

module ArithmeticLogicUnitSystem(
    // REGISTER FILE
    input wire [2:0] RF_OutASel,  // Register File Output A Selector 
    input wire [2:0] RF_OutBSel,  // Register File Output B Selector 
    input wire [2:0] RF_FunSel,   // Register File Function Selector 
    input wire [3:0] RF_RegSel,   // Register File General Purpose Register Selector 
    input wire [3:0] RF_ScrSel,   // Register File Scratch Register Selector 
    wire [15:0] OutA,             // 16-Bit Output A
    wire [15:0] OutB,             // 16-Bit Output B
    
    // ALU 
    input wire [4:0] ALU_FunSel,  // Arithmetic Logic Unit Function Selector
    input wire ALU_WF,            // Arithmetic Logic Unit Write Flag
    wire [3:0] Flags,             // 4-Bit Flags Register
    wire [15:0] ALUOut,           // 16-Bit Arithmetic Logic Unit Output 
    
    // ADDRESS REGISTER FILE
    input wire [1:0] ARF_OutCSel, // Address Register File Output C Selector
    input wire [1:0] ARF_OutDSel, // Address Register File Output D Selector
    input wire[2:0] ARF_FunSel,   // Address Register File Function Selector
    input wire[2:0] ARF_RegSel,   // Address Register File Register Selector
    wire [15:0] OutC,             // 16-Bit Address Register File Output C 
    wire [15:0] OutD,             // 16-Bit Address Register File Output D
    
    // INSTRUCTION REGISTER
    input wire IR_LH,             // Instruction Register Low/High Bit Selector
    input wire IR_Write,          // Instruction Register Write Flag
    wire [15:0] IROut,            // 16-Bit Instruction Register Output
    
    // MEMORY 
    input wire Mem_WR,            
    input wire Mem_CS,
    wire [7:0] MemOut,
    wire [15:0] Address,
    
    // MUX A/B/C
    input wire [1:0] MuxASel,     // Multiplexer A Selector
    wire [15:0] MuxAOut,          // 16-Bit Multiplexer A Output
     
    input wire [1:0] MuxBSel,     // Multiplexer B Selector
    wire [15:0] MuxBOut,          // 16-Bit Multiplexer B Output
    
    input wire MuxCSel,           // Multiplexer C Selector
    wire [7:0] MuxCOut,           // 8-Bit Multiplexer C Output
    
    input wire Clock              // Clock Signal

    // FLAGOUT
    //output reg Z, C, N, O         // Zero | Carry | Negative | Overflow 

);

    assign Address = OutD;        // Same wire
    //assign Flags = {Z, C, N, O};

    // MEMORY
    Memory MEM( .Address(Address), 
                .Data(MuxCOut), 
                .WR(Mem_WR), 
                .CS(Mem_CS), 
                .Clock(Clock), 
                .MemOut(MemOut) );
    
    // ALU
    ArithmeticLogicUnit ALU( .A(OutA), 
                             .B(OutB), 
                             .FunSel(ALU_FunSel), 
                             .WF(ALU_WF), 
                             .Clock(Clock), 
                             .ALUOut(ALUOut), 
                             .FlagsOut(Flags) );
    
    // IR REGISTER
    InstructionRegister #(16) IR( .I(MemOut), 
                                  .Write(IR_Write), 
                                  .LH(IR_LH), 
                                  .Clock(Clock), 
                                  .IROut(IROut));
    
    // RegisterFile
    RegisterFile RF( .I(MuxAOut), 
                     .OutASel(RF_OutASel), 
                     .OutBSel(RF_OutBSel), 
                     .FunSel(RF_FunSel), 
                     .RegSel(RF_RegSel), 
                     .ScrSel(RF_ScrSel), 
                     .Clock(Clock), 
                     .OutA(OutA), 
                     .OutB(OutB));
       
    // ADDRESS REGISTER FILE
    AddressRegisterFile ARF( .I(MuxBOut), 
                             .OutCSel(ARF_OutCSel), 
                             .OutDSel(ARF_OutDSel), 
                             .FunSel(ARF_FunSel), 
                             .RegSel(ARF_RegSel), 
                             .Clock(Clock), 
                             .OutC(OutC), 
                             .OutD(OutD) );
                     
    // MUX A
    MUX_16 MUXA( .S(MuxASel), 
                 .I_0(ALUOut), 
                 .I_1(OutC), 
                 .I_2(MemOut), 
                 .I_3(IROut[7:0]), 
                 .out(MuxAOut) );
    
    // MUX B
    MUX_16 MUXB( .S(MuxBSel), 
                 .I_0(ALUOut), 
                 .I_1(OutC), 
                 .I_2(MemOut), 
                 .I_3(IROut[7:0]), 
                 .out(MuxBOut) );
    
    // MUX C
    MUX_8 MUXC( .S(MuxCSel), 
                .I(ALUOut), 
                .out(MuxCOut) );
    
endmodule