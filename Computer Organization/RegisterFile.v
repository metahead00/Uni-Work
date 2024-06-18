`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU COMPUTER ENGINEERING DEPARTMENT
// Engineer: MELIKE BESPARMAK - RACHA BADREDDINE
// 
// Date : 04/04/2024
// Module Name: RegisterFile
// Project Name: COMPUTER ORGANIZATION PROJECT-1
//////////////////////////////////////////////////////////////////////////////////
`include "Register.v"

module RegisterFile(
    input wire [15:0] I,      //Input Data
    input wire [2:0] OutASel, //Output A Selector
    input wire [2:0] OutBSel, //Output B Selector
    input wire [2:0] FunSel,  //Function Selector
    input wire [3:0] RegSel,  //General Purpose Register Selector 
    input wire [3:0] ScrSel,  //Scratch Register Selector
    input wire Clock,         //Clock Signal
    output reg [15:0] OutA,   //Output A
    output reg [15:0] OutB    //Output B
    );
    
    wire E_R1, E_R2, E_R3, E_R4, E_S1, E_S2, E_S3, E_S4;       //Registers' Enables 
    wire [15:0] Q_R1, Q_R2, Q_R3, Q_R4, Q_S1, Q_S2, Q_S3, Q_S4;//Registers' Outputs
    
    assign {E_R1, E_R2, E_R3, E_R4} = ~RegSel; //R Registers Enabled according to the complement of RegSEL 
    assign {E_S1, E_S2, E_S3, E_S4} = ~ScrSel; //S Registers Enabled according to the complement of ScrSEL 
 
    //General Purpose Registers   
    Register #(16) R1(.FunSel(FunSel), .I(I), .E(E_R1), .Clock(Clock), .Q(Q_R1)); 
    Register #(16) R2(.FunSel(FunSel), .I(I), .E(E_R2), .Clock(Clock), .Q(Q_R2));
    Register #(16) R3(.FunSel(FunSel), .I(I), .E(E_R3), .Clock(Clock), .Q(Q_R3));
    Register #(16) R4(.FunSel(FunSel), .I(I), .E(E_R4), .Clock(Clock), .Q(Q_R4));

    //Scratch Registers    
    Register #(16) S1(.FunSel(FunSel), .I(I), .E(E_S1), .Clock(Clock), .Q(Q_S1));
    Register #(16) S2(.FunSel(FunSel), .I(I), .E(E_S2), .Clock(Clock), .Q(Q_S2));
    Register #(16) S3(.FunSel(FunSel), .I(I), .E(E_S3), .Clock(Clock), .Q(Q_S3));
    Register #(16) S4(.FunSel(FunSel), .I(I), .E(E_S4), .Clock(Clock), .Q(Q_S4));
  
      
    always @(*)
        begin
            //Output A depends on its selector
            case(OutASel)
                3'b000 : OutA <= Q_R1; //Output A: R1 
                3'b001 : OutA <= Q_R2; //Output A: R2
                3'b010 : OutA <= Q_R3; //Output A: R3
                3'b011 : OutA <= Q_R4; //Output A: R4
                3'b100 : OutA <= Q_S1; //Output A: S1
                3'b101 : OutA <= Q_S2; //Output A: S2
                3'b110 : OutA <= Q_S3; //Output A: S3
                3'b111 : OutA <= Q_S4; //Output A: S4
            endcase
            
            //Output B depends on its selector
            case(OutBSel)
                3'b000 : OutB <= Q_R1; //Output A: R1
                3'b001 : OutB <= Q_R2; //Output A: R2
                3'b010 : OutB <= Q_R3; //Output A: R3
                3'b011 : OutB <= Q_R4; //Output A: R4
                3'b100 : OutB <= Q_S1; //Output A: S1
                3'b101 : OutB <= Q_S2; //Output A: S2
                3'b110 : OutB <= Q_S3; //Output A: S3
                3'b111 : OutB <= Q_S4; //Output A: S4 
            endcase
        end   
endmodule