`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU COMPUTER ENGINEERING DEPARTMENT
// Engineer: MELIKE BESPARMAK - RACHA BADREDDINE
// 
// Date : 04/04/2024
// Module Name: REGISTER
// Project Name: COMPUTER ORGANIZATION PROJECT-1
//////////////////////////////////////////////////////////////////////////////////


module Register #(parameter n = 16)( 
    input wire [2:0] FunSel, //Function Selection
    input wire [n -1:0] I,   //Input Data
    input wire E,            //Enable
    input wire Clock,        //Clock Signal
    output reg [n -1:0] Q ); //Output Data

    always @(posedge Clock) //Works at positive edge 
        begin
            if(E) //Works if it is enabled
                begin
                    case(FunSel)
                        3'b000 : Q <= Q - {{n-1{1'b0}},1'b1}; //Q - 1
                        3'b001 : Q <= Q + {{n-1{1'b0}},1'b1}; //Q + 1
                        3'b010 : Q <= I[n-1:0];               //Load 
                        3'b011 : Q <= {n{1'b0}};              //Clear
                        3'b100 : begin 
                                    Q[n-1:8] <= {1'b0};       //Clear 8 MSB
                                    Q[7:0] <= I[7:0];         //Write to 8 LSB
                                 end
                        3'b101 : Q[7:0] <= I[7:0];            //Write to 8 LSB
                        3'b110 : Q[n-1:8] <= I[7:0];          //Write to 8 MSB
                        3'b111 : begin
                                    Q[n-1:8] <= {n/2{I[7]}};  //Extend Sign Bit of I to 8 MSB
                                    Q[7:0] <= I[7:0];         //Write to 8 LSB                                  
                                 end  
                        default : Q <= Q; //Default is Retaining Value
                    endcase
                end
            else //If not Enabled, Retain Value
                begin
                    Q<=Q;
                end
        end
endmodule