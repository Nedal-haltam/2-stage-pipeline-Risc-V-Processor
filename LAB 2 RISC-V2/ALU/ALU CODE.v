module ALU(A, B, res, ZF, CF, ALUOP);/////////////////////////////

parameter BW = 64; // BIT WIDTH
input [63:0] A,B;
input [2:0] ALUOP;
output reg [63:0] res;
output reg ZF, CF;

always @* begin

case (ALUOP)

    3'b000: begin
    {CF , res} = A + B;
    end
    3'b001: begin
    {CF , res} = A - B;
    end   
    3'b010: begin
    {CF , res} = A & B;
    end   
    3'b011: begin
    {CF , res} = A | B;
    end   
    3'b100: begin
    {CF , res} = A ^ B;
    end
    3'b101: begin // I shift A (B times)
    // if B (the shift amount) is greater than 64(BW) we let it zero else we take the last bit shifted to the left of A
    CF = (B > BW) ? 0 : CF&(B == 0) | (A[BW - B])&(B != 0);
    res = A << B;
    end
    3'b110: begin
      // when shifting to the right I let the carry equal to the last bit shifted to the right (opposite of shift left)
    CF = (B > BW) ? 0 : CF&(B == 0) | (A[B - 1])&(B != 0);
    res = A >> B;
    end
endcase
    // the zero flag is high if and only if all bits are low so I did an or gate first (as a reduction operator) 
    // and then invert it
    ZF = ~|res;
end
endmodule


module test_ALU;

parameter BW = 64;
reg signed [BW - 1:0] A, B;
reg [2:0] ALUOP;

wire signed [BW - 1:0] res;
wire ZF, CF;

ALU alu(A, B, res, ZF, CF, ALUOP);

initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
$monitor("ALUOP = %d , A = %d , B = %d , res = %d , CF = %b , ZF = %b"
, ALUOP, A, B, res, CF, ZF);

A = 0; B = 10; ALUOP = 0;
#1 A = 1; B = 5; ALUOP =  0;
#1 A = 2; B = 6; 
#1 A = 3; B = 6; 
#1 A = 4; B = 7; 
#1 A = 5; B = 8; 
#1 A = 0; B = 9; 
#1 A = 3; B = 0; 
#1 A = 7; B = 15;
#1 A = 12; B = 0;


#1 A = 0; B = 10; ALUOP = 1;
#1 A = 1; B = 5; 
#1 A = 2; B = 6; 
#1 A = 3; B = 6; 
#1 A = 4; B = 7; 
#1 A = 5; B = 8; 
#1 A = 0; B = 9; 
#1 A = 3; B = 0; 
#1 A = 7; B = 15;
A = 12; B = 0;   


#1 A = 0; B = 10; ALUOP = 2;
#1 A = 1; B = 5; 
#1 A = 2; B = 6; 
#1 A = 3; B = 6; 
#1 A = 4; B = 7; 
#1 A = 5; B = 8; 
#1 A = 0; B = 9; 
#1 A = 3; B = 0; 
#1 A = 7; B = 15;
#1 A = 12; B = 0;


#1 A = 0; B = 10; ALUOP = 3;
#1 A = 1; B = 5; 
#1 A = 2; B = 6; 
#1 A = 3; B = 6; 
#1 A = 4; B = 7; 
#1 A = 5; B = 8; 
#1 A = 0; B = 9; 
#1 A = 3; B = 0; 
#1 A = 7; B = 15;
#1 A = 12; B = 0;


#1 A = 0; B = 10; ALUOP = 4;
#1 A = 1; B = 5; 
#1 A = 2; B = 6; 
#1 A = 3; B = 6; 
#1 A = 4; B = 7; 
#1 A = 5; B = 8; 
#1 A = 0; B = 9; 
#1 A = 3; B = 0; 
#1 A = 7; B = 15;
#1 A = 12; B = 0;


#1 A = 0; B = 10; ALUOP = 5;
#1 A = 1; B = 5; 
#1 A = 2; B = 6; 
#1 A = 3; B = 6; 
#1 A = 4; B = 7; 
#1 A = 5; B = 8; 
#1 A = -1; B = 9;
#1 A = -1; B = 0;
#1 A = 3; B = 0; 
#1 A = 3; B = 1; 
#1 A = 7; B = 15;
#1 A = 12; B = 0;


  
#1 A = 0; B = 1; ALUOP = 6;
#1 A = 1; B = 1; 
#1 A = 2; B = 1; 
#1 A = 3; B = 1; 
#1 A = 4; B = 1; 
#1 A = 5; B = 1; 
#1 A = 0; B = 1; 
#1 A = 3; B = 1; 
#1 A = 7; B = 15;
#1 A = 12; B = 0;
#1 A = 3; B = 1; 
#1 A = 3; B = 0; 
#1 A = 3; B = 1; 
#1 A = 2; B = 1; 

  
  $finish;
end

endmodule


