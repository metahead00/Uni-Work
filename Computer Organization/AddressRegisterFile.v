`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU COMPUTER ENGINEERING DEPARTMENT
// Engineer: MELIKE BESPARMAK - RACHA BADREDDINE
// 
// Date : 04/04/2024
// Module Name: AddressRegisterFile
// Project Name: COMPUTER ORGANIZATION PROJECT-1
//////////////////////////////////////////////////////////////////////////////////

`include "Register.v"

module AddressRegisterFile(
    input wire [15:0] I,        //Input Data
    input wire [1:0] OutCSel,   //C Output Selector
    input wire [1:0] OutDSel,   //D Output Selector
    input wire [2:0] FunSel,    //Function Selector
    input wire [2:0] RegSel,    //Register Selector
    input wire Clock,           //Clock Signal
    output reg [15:0] OutC,     //C Output
    output reg [15:0] OutD      //D Output
    );

    //Registers' Enables    
    wire E_PC, E_AR, E_SP;
    
    //Registers' Outputs
    wire [15:0] Q_PC, Q_AR, Q_SP;

    //Registers Enabled according to the complement of RegSEL
    assign {E_PC, E_AR, E_SP} = ~RegSel;
    
    //Registers
    Register #(16) PC (.FunSel(FunSel), .I(I), .E(E_PC), .Clock(Clock), .Q(Q_PC));
    Register #(16) AR (.FunSel(FunSel), .I(I), .E(E_AR), .Clock(Clock), .Q(Q_AR));
    Register #(16) SP (.FunSel(FunSel), .I(I), .E(E_SP), .Clock(Clock), .Q(Q_SP));
    
    always @(*)
        begin
            //C Output depends on its Selector
            case(OutCSel)
                2'b00 : OutC <= Q_PC; //Output C : PC Register
                2'b01 : OutC <= Q_PC; //Output C : PC Register
                2'b10 : OutC <= Q_AR; //Output C : AR Register
                2'b11 : OutC <= Q_SP; //Output C : SP Register
            endcase
            
            //D Output depends on its selector
            case(OutDSel)
                2'b00 : OutD <= Q_PC; //Output D : PC Register
                2'b01 : OutD <= Q_PC; //Output D : PC Register
                2'b10 : OutD <= Q_AR; //Output D : AR Register
                2'b11 : OutD <= Q_SP; //Output D : SP Register
            endcase
        end

endmodule