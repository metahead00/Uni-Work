`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU COMPUTER ENGINEERING DEPARTMENT
// Engineer: MELIKE BESPARMAK - RACHA BADREDDINE
// 
// Date : 04/04/2024
// Module Name: ArithmeticLogicUnit
// Project Name: COMPUTER ORGANIZATION PROJECT-1
//////////////////////////////////////////////////////////////////////////////////

module ArithmeticLogicUnit(
    input wire [15:0] A,     // Input Data A
    input wire [15:0] B,     // Input Data B
    input wire [4:0] FunSel, // Function Selector
    input wire WF,           // Write Flag
    input wire Clock,        // Clock Signal
    output reg [15:0] ALUOut,// ALU Output
    output reg [3:0] FlagsOut// Flagsoutput Register
);                                   
     reg Z; // Zero Flag            
     reg C; // Carry Flag         
     reg N; // Negative Flag
     reg O; // Overflow Flag
     // Z|C|N|O
     

    integer sign_bit; // Sign Bit changes depending on Data(8 or 16 bits)

    always @(*) 
    begin
        ALUOut[15:8] = 0; // msb 8 bits 0, if 16 it will be overwritten

        // The Data Size hence Sign Bit depend on the MSB of Function Selector
        if(FunSel[4])
            begin
                // If Data is 16 bits
                sign_bit = 15;
            end 
        else 
            begin
                // If data is 8 bits 
                sign_bit = 7;

            end
        
        // Operations Depending on the rest 4 bits of Function Selector 
        case(FunSel[3:0]) 
            4'b0000 :  ALUOut = A;  // Output A
            4'b0001 :  ALUOut = B;  // Output B
            4'b0010 :  ALUOut = ~A; // Output Complement A
            4'b0011 :  ALUOut = ~B; // Output Complement B
            
            // Arithmetic Operations
            4'b0100 :  // A + B                  
                begin               
                    // Start with 8 bits
                    {C, ALUOut[7:0]} = {1'b0, A[7:0]} + {1'b0, B[7:0]};
                    
                    // If Data is 16 Continue
                    if(FunSel[4])
                            {C, ALUOut[15:8]} = {1'b0, A[15:8]} + {1'b0, B[15:8]} + {8'd0, C};
                       
                    // Overflow Flag Update 
                    if(A[sign_bit]==B[sign_bit] && ALUOut[sign_bit]!=B[sign_bit]) 
                        O = 1;
                    else
                        O = 0;                                  
                end
                
            4'b0101 :  // A + B + Carry
                begin               
                    // Start with 8 bits      
                    {C, ALUOut[7:0]} = {1'b0, A[7:0]} + {1'b0, B[7:0]} + {8'd0, FlagsOut[2]};
                     
                    // If Data is 16 Continue                  
                    if(FunSel[4] == 1)
                            {C, ALUOut[15:8]} = {1'b0, A[15:8]} + {1'b0, B[15:8]} + {8'd0, C};
                            
                    // Overflow Flag Update        
                    if(A[sign_bit]==B[sign_bit] && ALUOut[sign_bit]!=B[sign_bit]) 
                        O = 1;
                    else
                        O = 0;              
                end 
                
            4'b0110 :  // A - B 
                begin                              
                  // Start with 8 bits            
                  {C, ALUOut[7:0]} = {1'b0, A[7:0]} + {1'b0, ~B[7:0]} + 9'd1 ; // 2's Complement
                  
                  // If Data is 16 Continue
                  if(FunSel[4] == 1)
                          {C, ALUOut[15:8]} = {1'b0, A[15:8]} + {1'b0, ~B[15:8]} + {8'd0, C};
                  //Carry works as a Borrow in this operation       
                  C = ~C;
                  
                  // Overflow Flag Update
                  if(A[sign_bit]!=B[sign_bit] && ALUOut[sign_bit]==B[sign_bit]) 
                      O = 1;
                  else
                      O = 0;                
                end
             
            // Logic Operations    
            4'b0111 :  ALUOut = A & B;    // A and B
            4'b1000 :  ALUOut = A | B;    // A or B   
            4'b1001 :  ALUOut = A ^ B;    // A xor B  
            4'b1010 :  ALUOut = ~(A & B); // A nand B
            
            // Shift Operations
            4'b1011 :  // LSL : Logical Shift Left 
                begin
                    C = A[sign_bit];
                    ALUOut = A;
                    ALUOut = ALUOut << 1;     
                end 
                  
            4'b1100 :  // LSR : Logical Shift Right
                begin
                     C = A[0];
                     ALUOut = A;
                     ALUOut = ALUOut >> 1;
                     
                     ALUOut[sign_bit] = 0;
                     
                     // Negative Flag Update Always 0 is inserted
                     N = 0;      
                end 
                 
            4'b1101 :  // ASR : Arithmetic Shift Right
                begin               
                    ALUOut = A;
                    ALUOut = ALUOut >> 1;
                    
                    ALUOut[sign_bit] = ALUOut[sign_bit -1];                      
                end 
                
            4'b1110 :  // CSL : Circular Shift Left
                begin
                    ALUOut = {A[14: 0], FlagsOut[2]};
                    C = A[sign_bit];
                end  
                
            4'b1111 :  // CSR : Circular Shift Right
                 begin
                      ALUOut = {FlagsOut[2], A[15:1]};
                      
                       // if 8 bits            
                      if(~FunSel[4])          
                           ALUOut[sign_bit] = C; 
                           
                       C = A[0]; 
                   end
                
                                                                       
        endcase
        
        // Negative Flag Update
        if(ALUOut[sign_bit])
             N = 1;
        else
             N = 0;
    
        // Zero Flag Update    
        if(ALUOut == 16'd0)
            Z = 1;
        else
            Z = 0; 
              
    end
  
    // Update Flags Register depending on the Clock Signal  
    always @(posedge Clock) 
        begin
            // Works if Write Flag is Enabled
            if(WF)
                begin
                    case(FunSel[3:0])
                        4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0111, 4'b1000, 4'b1001, 4'b1010:
                            begin
                                FlagsOut[3] = Z;
                                FlagsOut[1] = N;
                            end
                        4'b0100, 4'b0101, 4'b0110: FlagsOut <= {Z, C, N, O}; 
                        4'b1101: 
                            begin
                                FlagsOut[3] = Z;
                                FlagsOut[2] = C;
                            end
                        4'b1011, 4'b1100, 4'b1110, 4'b1111:
                            begin
                                FlagsOut[3] = Z;
                                FlagsOut[2] = C;
                                FlagsOut[1] = N;
                            end
                    endcase
                
                end
        end
endmodule