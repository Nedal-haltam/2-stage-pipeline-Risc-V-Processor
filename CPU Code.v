module MUX_2x1(ina , inb , sel , out);///////////////////////////////////

input [63:0] ina , inb;
input sel;

output reg [63:0] out;

always@ (*)
    out = (!sel) ? ina : inb;

endmodule

module MUX_4x1(ina, inb, inc, ind, sel, out);/////////////////////////////

input [63:0] ina , inb , inc , ind; 
input [1:0] sel;

output reg [63:0] out;

always@ (*) begin

case (sel)

    2'b00: out = ina;

    2'b01: out = inb;
    
    2'b10: out = inc;
    
    2'b11: out = ind;
    
endcase
end
endmodule

module MUX_8x1(ina , inb , inc , ind , ine , inf , ing , inh, sel, out);/////////////////////////////

input [63:0] ina , inb , inc , ind , ine , inf , ing , inh;
input [2:0] sel;

output reg [63:0] out;

always@ (*) begin

case (sel)

    3'b000: out = ina;

    3'b001: out = inb;
    
    3'b010: out = inc;
    
    3'b011: out = ind;
    
    3'b100: out = ine;

    3'b101: out = inf;
    
    3'b110: out = ing;
    
    3'b111: out = inh;
    
endcase
end 
endmodule

module Branch_oper_mux(_reg,immed, func3_opcode, out);
  
input [11:0] immed;
input [63:0] _reg;
input [9:0] func3_opcode;  
output reg [63:0] out;
  
always@ (*) begin
  
  if (func3_opcode[6:0] == 7'b0010011) begin
    if (func3_opcode[9:7] == 3'b010)
      out = {{52{immed[11]}}, immed};
    else
      out = {52'd0, immed};
  end
  else
    out = _reg;
    
end
endmodule


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


module REG_FILE(rd_reg1, rd_reg2, wr_reg, wr_data, rd_data1, rd_data2, reg_wr,clk);////////////////////////////////

input [63:0] wr_data;
input [4:0] rd_reg1, rd_reg2, wr_reg;
input reg_wr, clk;

output reg [63:0] rd_data1, rd_data2;

reg [63:0] reg_file [31:0];
integer i;
  
// initializing the register file so I can operate on them normaly and not on an unknown value (x)
initial
  for(i = 0; i < 32; i = i + 1)
    reg_file[i] = 64'd0;
  
always@ (rd_reg1 or rd_reg2 or clk) begin

rd_data1 = reg_file[rd_reg1];
rd_data2 = reg_file[rd_reg2];

end

always@ (posedge clk) begin
    
  if(reg_wr == 1 && wr_reg != 5'd0)
	reg_file[wr_reg] = wr_data;

end
endmodule


module MEM(addr , Data_In , Data_Out , WR , clk);/////////////////////////////////////

input [63:0] addr , Data_In;
input WR , clk;
output reg [63:0] Data_Out;

reg [63:0] data_mem [1023: 0];

always@ (addr or clk) 
    Data_Out = data_mem[addr];

  
always@ (posedge clk)
    if (WR == 1'b1)
        data_mem[addr] = Data_In;

endmodule

module Branch_CondGen(Rs1 , Rs2 , eq , lt , ltu);///////////////////////////////

input [63:0] Rs1 , Rs2;
output reg eq , lt , ltu;


always@(Rs1 or Rs2) begin

eq = (Rs1 == Rs2) ? 1'b1 : 1'b0;

lt = ($signed(Rs1) < $signed(Rs2)) ? 1'b1 : 1'b0;

ltu = (Rs1 < Rs2) ? 1'b1 : 1'b0;

end

endmodule

// set less than (signed / unsigned) based on the func3 & opcode
module set_less_than(eq, lt, ltu, func3_opcode, SLT_out);////////////////////////////////

input eq, lt, ltu;
input [9:0] func3_opcode;
output reg [63:0] SLT_out;

always@ (*) begin
// it is signed comparison if the instruction is SLT or SLTI (the func3 is equal to 010)
// otherwise it is unsigned comparison SLTU or SLTIU (the func3 is equal to 011)

SLT_out = (func3_opcode[9:7] == 3'b010) ? lt : ltu;

end
endmodule


module Branch_Jump_TargGen(PC , Immed , targ_addr);///////////////////////////////

input [63:0] PC , Immed;


output reg [63:0] targ_addr;

always@ (*)
    targ_addr = PC + Immed;

endmodule


///////////////////////////////////////////////
module Control_Unit(Inst , kill_IF , PC_src , ALU_srcA , ALU_srcB , ALU_OP , mem_wr , reg_wr , wr_reg , wr_data_reg_src, hlt , eq, lt, ltu);

input [31:0] Inst;
input eq, lt, ltu;


 
// registers to save the Instruction main parts (I can use concatination and indexing but this is 
// easier and readable
reg [6:0] opcode;
reg [2:0] func3;
reg [6:0] func7;
// control signals
output reg ALU_srcA, reg_wr, mem_wr, kill_IF, wr_reg, hlt = 1'b0;
output reg [1:0] PC_src, wr_data_reg_src;
output reg [2:0] ALU_srcB;
output reg [2:0] ALU_OP;


always@ (*) begin

opcode = Inst[6:0];
func3 = Inst[9:7];
func7 = Inst[16:10];
case (opcode)

    7'b0010011: // arithmetic (I-format)
    begin
    PC_src = 2'b00; 
    wr_data_reg_src = 2'b10;
    wr_reg = 1'b1;
    mem_wr = 1'b0;
    reg_wr = 1'b1;
    kill_IF = 1'b0;
    ALU_srcA = 1'b0;
        case (func3)
            3'd0: 
            begin
            ALU_srcB = 3'd3;
            ALU_OP = 3'd0;
            end
            3'd1:        
            begin
            ALU_srcB = 3'd2;
            ALU_OP = 3'd5;
            end
            3'd2:
            begin
            ALU_srcB = 3'b000;
            ALU_OP = 3'b000;
            wr_data_reg_src = 2'b00;
            end
            3'd3:        
            begin
            ALU_srcB = 3'b000;
            ALU_OP = 3'b000;
            wr_data_reg_src = 2'b00;
            end
            3'd4:        
            begin
            ALU_srcB = 3'd3;
            ALU_OP = 3'd4;
            end
            3'd5:        
            begin
            ALU_srcB = 3'd2;
            ALU_OP = 3'd6;
            end
            3'd6:        
            begin
            ALU_srcB = 3'd3;
            ALU_OP = 3'd3;
            end
            3'd7:        
            begin
            ALU_srcB = 3'd3;
            ALU_OP = 3'd2;
            end
        endcase
    end
    7'b0110011: // arithmetic (R-format)
    begin
    PC_src = 2'b00; 
    wr_data_reg_src = 2'b10;
    wr_reg = 1'b1;
    mem_wr = 1'b0;
    reg_wr = 1'b1;
    kill_IF = 1'b0;
    ALU_srcA = 1'b0;
    ALU_srcB = 3'd4;
        case (func3)
            3'd0: ALU_OP = { 2'b00 , func7[6] };
            3'd1: ALU_OP = 3'd5;
            3'd2: begin
            ALU_OP = 3'b000; 
            wr_data_reg_src = 2'b00;
            end
            3'd3: begin
            ALU_OP = 3'b000; 
            wr_data_reg_src = 2'b00; 
            end
            3'd4: ALU_OP = 3'd4;
            3'd5: ALU_OP = 3'd6;
            3'd6: ALU_OP = 3'd3;
            3'd7: ALU_OP = 3'd2;
        endcase
    end
    7'b0110111: // LUI
    begin
    PC_src = 2'd0; 
    kill_IF = 1'd0;
    ALU_srcA = 1'd1;
    ALU_srcB = 3'd0;
    ALU_OP = 3'd0;
    mem_wr = 1'd0;
    reg_wr = 1'd1;
    wr_reg = 1'd1;
    wr_data_reg_src = 2'd2;
    end
    7'b0000011: // load inst
    begin
    PC_src = 2'd0; 
    kill_IF = 1'd0;
    ALU_srcA = 1'd0;
    ALU_srcB = 3'd3;
    ALU_OP = 3'd0;
    mem_wr = 1'd0;
    reg_wr = 1'd1;
    wr_reg = 1'd1;
    wr_data_reg_src = 2'd3;
    end
    7'b0100011: // store inst
    begin
    PC_src = 2'd0; 
    kill_IF = 1'd0;
    ALU_srcA = 1'd0;
    ALU_srcB = 3'd1;
    ALU_OP = 3'd0;
    mem_wr = 1'd1;
    reg_wr = 1'd0;
    wr_reg = 1'd1;
    wr_data_reg_src = 2'd2;
    end
    7'b1100011: // branch Instructions
    begin
    kill_IF = 1'd0;
    ALU_srcA = 1'd0;
    ALU_srcB = 3'd0;
    ALU_OP = 3'd0;
    mem_wr = 1'd0;
    reg_wr = 1'd0;
    wr_reg = 1'd0;
    wr_data_reg_src = 2'd2;
        case (func3)
            3'd0: PC_src = (eq) ? 2'd1 : 2'd0;
            3'd1: PC_src = (!eq) ? 2'd1 : 2'd0;
            3'd4: PC_src = (lt) ? 2'd1 : 2'd0;
            3'd5: PC_src = (!lt) ? 2'd1 : 2'd0;
            3'd6: PC_src = (ltu) ? 2'd1 : 2'd0;
            3'd7: PC_src = (!ltu) ? 2'd1 : 2'd0;
        endcase
    end
    7'b1100111: // j
    begin
    kill_IF = 1'd0;
    ALU_srcA = 1'd0;
    ALU_srcB = 3'd0;
    ALU_OP = 3'd0;
    mem_wr = 1'd0;
    reg_wr = 1'd0;
    wr_reg = 1'd0;
    wr_data_reg_src = 2'd0;
    PC_src = 2'd2;
    end
    7'b1101111: // jal
    begin
    PC_src = 2'd2; 
    kill_IF = 1'd0;
    ALU_srcA = 1'd0;
    ALU_srcB = 3'd0;
    ALU_OP = 3'd0;
    mem_wr = 1'd0;
    reg_wr = 1'd1;
    wr_reg = 1'd0;
    wr_data_reg_src = 2'd1;
    end
    7'b1101011: // jalr
    begin
    PC_src = 2'd3; 
    kill_IF = 1'd0;
    ALU_srcA = 1'd0;
    ALU_srcB = 3'd3;
    ALU_OP = 3'd0;
    mem_wr = 1'd0;
    reg_wr = 1'd1;
    wr_reg = 1'd1;
    wr_data_reg_src = 2'd1;
    end
    7'b1111111: // hlt
      begin
        hlt = 1'b1;
        mem_wr = 1'd0;
        reg_wr = 1'd0;
      end
      
    
endcase

  if(opcode == 0) begin
    
    kill_IF = 1'b0; ALU_srcA = 1'b0; reg_wr = 1'b0; mem_wr = 1'b0; wr_reg = 1'b0;
    PC_src = 2'b00; wr_data_reg_src = 2'b00;
    ALU_srcB = 3'b000; ALU_OP = 3'b000;
    
  end

else begin
// for debugging
// $display("");
// $display("%b %b %b %b %b %b %b %b %b , %b",kill_IF , PC_src , ALU_srcA , ALU_srcB , ALU_OP , mem_wr , reg_wr , wr_reg , wr_data_reg_src,Signals);
end
end
endmodule


module Increament_PC(In , out);///////////////////////

input [63:0] In;
output reg [63:0] out;

always@ (*)
    out = In + 1;

endmodule


module CPU;///////////////////////////////////

reg input_clk=1;
  
wire clk, hlt;
  
output [63:0] IR_wire, PC_INC_wire, PC1_wire;

reg reg_sel_test, addr_sel_test;
reg [63:0] reg_index_test, mem_addr_test;
wire [63:0] read_reg_test, Data_mem_addr;

reg Inst_wr;
reg [63:0] PC1 , PC2 , PC_INC, Inst_to_wr;
reg [63:0] IR;

wire eq , lt, ltu, ZF, CF;
wire ALU_srcA, reg_wr, mem_wr, kill_IF, wr_reg;
wire [1:0] PC_src, wr_data_reg_src;
wire [2:0] ALU_srcB;
wire [2:0] ALU_OP;
wire [63:0] Inst, branch_wire, jump_wire, rs1, rs2, OPER2_wire, OPER1_wire, ALU_OUT_wire, Data_MEM_Out;
wire [63:0] wr_reg_wire;
wire [63:0] wr_data_wire_mux, SLT_out, Br_Cond_oper;
  
  nor hlt_logic(clk, input_clk, hlt);
  
MEM Inst_MEM(PC1 , Inst_to_wr , Inst , Inst_wr , clk);

MUX_2x1 inst_mux(Inst , 64'd0 , kill_IF , IR_wire);

Increament_PC Inc_PC(PC1, PC_INC_wire);

MUX_4x1 PC_src_mux(PC_INC_wire, branch_wire, jump_wire, ALU_OUT_wire, PC_src, PC1_wire);

Branch_Jump_TargGen Branch_Target_Gen(PC2, {{52{IR[31]}}, IR[31:27], IR[16:10]}, branch_wire);

Branch_Jump_TargGen Jump_Target_Gen(PC2, {{39{IR[31]}}, IR[31:7]}, jump_wire);

MUX_2x1 mux_to_read_reg1({59'd0, IR[26:22]}, reg_index_test , reg_sel_test , read_reg_test);

REG_FILE reg_file(read_reg_test[4:0], IR[21:17], wr_reg_wire[4:0], wr_data_wire_mux, rs1, rs2, reg_wr,clk);
  
Branch_oper_mux oper2_of_Branch_CondGen(rs2, IR[21:10], IR[9:0], Br_Cond_oper);

Branch_CondGen cond_gen(rs1 , Br_Cond_oper , eq , lt , ltu);

Control_Unit controlunit(IR[31:0] , kill_IF , PC_src , ALU_srcA , ALU_srcB , ALU_OP , mem_wr , reg_wr , wr_reg , wr_data_reg_src,hlt, eq, lt, ltu);

MUX_8x1 srcB(64'd0 , {{52{IR[31]}}, IR[31:27], IR[16:10]}, { 58'd0, IR[15:10] } , {{52{IR[21]}}, IR[21:10]} , rs2 , 64'd0 , 64'd0 , 64'd0, ALU_srcB, OPER2_wire);

MUX_2x1 srcA(rs1 , {32'd0, IR[26:7], 12'd0} , ALU_srcA , OPER1_wire); 

ALU alu(OPER1_wire, OPER2_wire, ALU_OUT_wire, ZF, CF, ALU_OP);
  
MUX_2x1 mux_to_read_mem(ALU_OUT_wire, mem_addr_test, addr_sel_test, Data_mem_addr);

MEM Data_MEM(Data_mem_addr , rs2 , Data_MEM_Out , mem_wr, clk);

set_less_than SLT(eq, lt, ltu, IR[9:0], SLT_out);

MUX_4x1 data_to_reg(SLT_out, PC_INC, ALU_OUT_wire, Data_MEM_Out, wr_data_reg_src, wr_data_wire_mux);

MUX_2x1 wr_reg_src(64'd1 , {59'd0, IR[31:27]} , wr_reg , wr_reg_wire);



always@ (posedge clk) begin

if (Inst_wr == 1'b0)
    PC1 <= PC1_wire;
  
end

always@ (negedge clk) begin

if (Inst_wr == 1'b0) begin
  
IR <= IR_wire;
PC_INC <= PC_INC_wire;
PC2 <= PC1;
  
end
  
  
end

always #1 input_clk <= ~input_clk;
  
reg [63:0] i, j;  
  


// in this initial block I test the CPU with various different combinations of the instructions 
initial begin
$dumpfile("dump.vcd");
$dumpvars;

$display("Writing On Instruction Memory...");
Inst_wr = 1; 
reg_sel_test = 0; 
addr_sel_test = 0;



// Instructions to write on memory in hex.

  
  

//  j = 2 * ((PC1 + 1) + 1); 
//time taken to finish a program based on the Inscruction count without loops is number of stages minus one plus number of Inst (PC1 + 1)
// and then multiply by two to get the amount of time units required (one clock cycle = 2 time units)
  
  
   
$display("Executing...");
Inst_wr = 0;
PC1 = 0; PC2 = 0; PC_INC = 0; IR = 0; 
// make sure you provide enough time for the program to run especially when using loops because in that case the IC 
// is how much the instruction got executed not how many instruction is written in the code
#200;

// doing a for-loop iterating through the register file to check if the program changed the contents correctly
reg_sel_test = 1;
  $display("Reading Register File : ");
  for (i = 0; i < 32; i = i + 1) begin
    reg_index_test = i[4:0]; #1; 
    $display("index = %d , reg_out : signed = %d , unsigned = %d",reg_index_test, $signed(rs1), rs1 );
  end
  

// doing a for-llop iterating through some of the addresses of the memory to check if the program loaded and stored the values properly
addr_sel_test = 1;
  $display("Reading Data Memory Content : ");
  for (i = 0; i < 32; i = i + 1) begin
    mem_addr_test = i; #1;
    $display("addr = %d , Mem[addr] = %d",mem_addr_test,Data_MEM_Out);
  end

$finish;

end
endmodule
