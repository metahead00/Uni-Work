`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU COMPUTER ENGINEERING DEPARTMENT
// Engineer: MELIKE BESPARMAK - RACHA BADREDDINE
// 
// Date : 04/04/2024
// Module Name: InstructionRegister
// Project Name: COMPUTER ORGANIZATION PROJECT-1
//////////////////////////////////////////////////////////////////////////////////

module InstructionRegister #(parameter n = 16)(
    input wire [7:0] I,     //Input Data
    input wire Write,       //Enable of Writing
    input wire LH,          //Selector of the 8 bit to be written
    input wire Clock,       //Clock Signal
    output reg [15:0] IROut //Output Data
);

    always @(posedge Clock) //Works at positive edge
        begin
            if(Write) //Works if Write is enabled
                begin
                    case(LH) //Selector
                        1'b0 : IROut[7:0] <= I[7:0]; //Write the 8 LSB
                        1'b1 : IROut[15:8] <= I[7:0];//Write the 8 MSB
                        default: IROut <= IROut;     //Default is Retaining Value
                    endcase                      
                end
            else //If not Enabled, Retain Value
                begin
                    IROut <= IROut;
                end
        end
    

endmodule