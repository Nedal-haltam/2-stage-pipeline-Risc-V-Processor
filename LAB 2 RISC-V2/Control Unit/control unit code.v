module Control_Unit(Inst , kill_IF , PC_src , ALU_srcA , ALU_srcB , ALU_OP , mem_wr , reg_wr , wr_reg , wr_data_reg_src, hlt , eq, lt, ltu);

input [31:0] Inst;
input eq, lt, ltu;



// registers to save the Instruction main parts (I can use concatination and indexing but this is 
// easier and readable)
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
  

module test_Control_Unit;

reg [31:0] Inst;
reg eq, lt, ltu;

wire kill_IF, ALU_srcA, mem_wr , reg_wr , wr_reg, hlt; 
wire [1:0] wr_data_reg_src, PC_src;
wire [2:0] ALU_srcB, ALU_OP;
Control_Unit control_unit(Inst , kill_IF , PC_src , ALU_srcA , ALU_srcB , ALU_OP , mem_wr , reg_wr , wr_reg , wr_data_reg_src, hlt , eq, lt, ltu);

initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
  $monitor("kill_IF = %b , PC_src = %b , ALU_srcA = %b , ALu_srcB = %b , ALU_OP = %b , mem_wr = %b, reg_wr = %b , wr_reg = %b , wr_data_reg_src = %b , eq = %b, lt = %b, ltu = %b",kill_IF , PC_src , ALU_srcA , ALU_srcB , ALU_OP , mem_wr , reg_wr , wr_reg , wr_data_reg_src,eq,lt,ltu);

  
  
  eq = 0; lt = 0; ltu = 0;
  $display("I-format Instructions"); // immediate instructions
Inst = 32'b000000000000000000000000; #1;
Inst = 32'b000000000000000000010011; #1;
Inst = 32'b000000000000000010010011; #1;
Inst = 32'b000000000000000100010011; #1;
Inst = 32'b000000000000000110010011; #1;
Inst = 32'b000000000000001000010011; #1;
Inst = 32'b000000000000001010010011; #1;
Inst = 32'b000000000000001100010011; #1;
Inst = 32'b000000000000001110010011; #1;

  $display("R-format Instructions"); // r-type instructions
Inst = 32'b00000000000000000000000000110011; #1;
Inst = 32'b00000000000000010000000000110011; #1;
Inst = 32'b00000000000000000000000010110011; #1;
Inst = 32'b00000000000000000000000100110011; #1;
Inst = 32'b00000000000000000000000110110011; #1;
Inst = 32'b00000000000000000000001000110011; #1;
Inst = 32'b00000000000000000000001010110011; #1;
Inst = 32'b00000000000000000000001100110011; #1;
Inst = 32'b00000000000000000000001110110011; #1;

  $display("LUI Instruction"); // lui
Inst = 32'b00000000000000000000000000110111; #1;

  $display("Load Instruction"); // load
Inst = 32'b00000000000000000000000100000011; #1;

  $display("store Instruction");// store
Inst = 32'b00000000000000000000000100100011; #1;

  $display("jump Instruction");// jump
Inst = 32'b00000000000000000000000001100111; #1;

  $display("jal Instruction");// jal
Inst = 32'b00000000000000000000000001101111; #1;

  $display("jalr Instruction");// jalr
Inst = 32'b00000000000000000000000001101011; #1;


$display("Branches INST : ");
Inst = 32'b00000000000000000000000001100011; eq = 0; #1;
Inst = 32'b00000000000000000000000001100011; eq = 1; #1;
Inst = 32'b00000000000000000000000011100011; eq = 0; #1;
Inst = 32'b00000000000000000000000011100011; eq = 1; #1;
Inst = 32'b00000000000000000000001001100011; lt = 0; #1;
Inst = 32'b00000000000000000000001001100011; lt = 1; #1;
Inst = 32'b00000000000000000000001011100011; lt = 0; #1;
Inst = 32'b00000000000000000000001011100011; lt = 1; #1;
Inst = 32'b00000000000000000000001101100011; ltu = 0; #1;
Inst = 32'b00000000000000000000001101100011; ltu = 1; #1;
Inst = 32'b00000000000000000000001111100011; ltu = 0; #1;
Inst = 32'b00000000000000000000001111100011; ltu = 1; #1;



end
endmodule
  
