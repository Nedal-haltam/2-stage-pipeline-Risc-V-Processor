module REG_FILE(rd_reg1, rd_reg2, wr_reg, wr_data, rd_data1, rd_data2, reg_wr,clk,rd_reg3, rd_data3);////////////////////////////////

// for testing purposes
  input [4:0] rd_reg3;
  output reg [63:0] rd_data3;
  
input [63:0] wr_data;
input [4:0] rd_reg1, rd_reg2, wr_reg;
input reg_wr, clk;

output reg [63:0] rd_data1, rd_data2;

reg [63:0] reg_file [31:0];
integer i;
  
// initializing the register file so I can operate on them normaly and not on an unknown value (x)
initial
  for(i = 0; i < 32; i = i + 1)
    reg_file[i] = i;
  
always@ (rd_reg1 or rd_reg2 or clk) begin

rd_data1 = reg_file[rd_reg1];
rd_data2 = reg_file[rd_reg2];
rd_data3 = reg_file[rd_reg3];

end

always@ (posedge clk) begin
    
  if(reg_wr == 1 && wr_reg != 5'd0)
	reg_file[wr_reg] = wr_data;

end
endmodule


module test_reg_file;

reg [63:0] wr_data;
reg [4:0] rd_reg1, rd_reg2, wr_reg;
reg reg_wr, clk=0;

reg [4:0] rd_reg3;
wire [63:0] rd_data3;

wire [63:0] rd_data1, rd_data2;

REG_FILE regfile(rd_reg1, rd_reg2, wr_reg, wr_data, rd_data1, rd_data2, reg_wr,clk
                ,rd_reg3, rd_data3);

always #2 clk <= ~clk;

initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
$monitor("reg_wr = %b, wr_data =%d , rd_reg1 = %d , rd_reg2 = %d , rd_reg3 = %d , wr_reg = %d , rd_data1 =%d , rd_data2 =%d , rd_data3 =%d",reg_wr,wr_data,rd_reg1,rd_reg2,rd_reg3,wr_reg,rd_data1,rd_data2,rd_data3);


$display("testing the Reading without writing : ");
reg_wr = 0; rd_reg3 = 21;
rd_reg1 = 10; rd_reg2 = 1;  wr_reg = 21;  wr_data = 65535; #4; rd_reg3 = wr_reg;
rd_reg1 = 21; rd_reg2 = 2;  wr_reg = 30;  wr_data = 65535; #4; rd_reg3 = wr_reg;
rd_reg1 = 30; rd_reg2 = 3;  wr_reg = 31;  wr_data = 65535; #4; rd_reg3 = wr_reg;
rd_reg1 = 31; rd_reg2 = 4;  wr_reg = 14;  wr_data = 65535; #4; rd_reg3 = wr_reg;
rd_reg1 = 14; rd_reg2 = 31; wr_reg = 23;  wr_data = 65535; #4; rd_reg3 = wr_reg;
rd_reg1 = 28; rd_reg2 = 23; wr_reg = 26;  wr_data = 65535; #4; rd_reg3 = wr_reg;
rd_reg1 = 2;  rd_reg2 = 26; wr_reg = 19;  wr_data = 65535; #4; rd_reg3 = wr_reg;
rd_reg1 = 18; rd_reg2 = 19; wr_reg = 1;   wr_data = 65535; #4; rd_reg3 = wr_reg;
rd_reg1 = 1;  rd_reg2 = 1;  wr_reg = 0;   wr_data = 65535; #4; rd_reg3 = wr_reg;
#4;

$display("testing Writing : ");
$monitor("reg_wr = %b, wr_data =%d , rd_reg3 = %d , wr_reg = %d , rd_data3 = %d",reg_wr,wr_data,rd_reg3,wr_reg,rd_data3);

wr_data = 65535;
$display("");
reg_wr = 0;
rd_reg1 = 10; rd_reg2 = 1;  wr_reg = 21; rd_reg3 = wr_reg; #4;
reg_wr = 1;
rd_reg1 = 10; rd_reg2 = 1;  wr_reg = 21; #4; 
reg_wr = 0;
rd_reg1 = 10; rd_reg2 = 1;  wr_reg = 21; #4;

wr_data = 111111;
$display("");
reg_wr = 0;
rd_reg1 = 21; rd_reg2 = 2;  wr_reg = 30; rd_reg3 = wr_reg; #4; 
reg_wr = 1;
rd_reg1 = 21; rd_reg2 = 2;  wr_reg = 30; #4; 
reg_wr = 0;
rd_reg1 = 21; rd_reg2 = 2;  wr_reg = 30; #4;

wr_data = 222222;
$display("");
reg_wr = 0;
rd_reg1 = 30; rd_reg2 = 3;  wr_reg = 31; rd_reg3 = wr_reg; #4;
reg_wr = 1;
rd_reg1 = 30; rd_reg2 = 3;  wr_reg = 31; #4; 
reg_wr = 0;
rd_reg1 = 30; rd_reg2 = 3;  wr_reg = 31; #4;

wr_data = 3333333;
$display("");
reg_wr = 0;
rd_reg1 = 31; rd_reg2 = 4;  wr_reg = 14; rd_reg3 = wr_reg; #4;
reg_wr = 1;
rd_reg1 = 31; rd_reg2 = 4;  wr_reg = 14; #4; 
reg_wr = 0;
rd_reg1 = 31; rd_reg2 = 4;  wr_reg = 14; #4;

wr_data = 4444444;
$display("");
reg_wr = 0;
rd_reg1 = 14; rd_reg2 = 31; wr_reg = 23; rd_reg3 = wr_reg; #4;
reg_wr = 1;
rd_reg1 = 14; rd_reg2 = 31; wr_reg = 23; #4; 
reg_wr = 0;
rd_reg1 = 14; rd_reg2 = 31; wr_reg = 23; #4;

wr_data = 5555555;
$display("");
reg_wr = 0;
rd_reg1 = 28; rd_reg2 = 23; wr_reg = 26; rd_reg3 = wr_reg; #4;
reg_wr = 1;
rd_reg1 = 28; rd_reg2 = 23; wr_reg = 26; #4; 
reg_wr = 0;
rd_reg1 = 28; rd_reg2 = 23; wr_reg = 26; #4;

wr_data = 6666666;
$display("");
reg_wr = 0;
rd_reg1 = 2;  rd_reg2 = 26; wr_reg = 19; rd_reg3 = wr_reg; #4;
reg_wr = 1;
rd_reg1 = 2;  rd_reg2 = 26; wr_reg = 19; #4; 
reg_wr = 0;
rd_reg1 = 2;  rd_reg2 = 26; wr_reg = 19; #4;

wr_data = 777777;
$display("");
reg_wr = 0;
rd_reg1 = 18; rd_reg2 = 19; wr_reg = 1;  rd_reg3 = wr_reg; #4;
reg_wr = 1;
rd_reg1 = 18; rd_reg2 = 19; wr_reg = 1;  #4; 
reg_wr = 0;
rd_reg1 = 18; rd_reg2 = 19; wr_reg = 1;  #4;

wr_data = 8888888;
$display("");
reg_wr = 0;
rd_reg1 = 1;  rd_reg2 = 1;  wr_reg = 0;  rd_reg3 = wr_reg; #4;
reg_wr = 1;
rd_reg1 = 1;  rd_reg2 = 1;  wr_reg = 0;  #4; 
reg_wr = 0;
rd_reg1 = 1;  rd_reg2 = 1;  wr_reg = 0;  #4;


$finish;
end



endmodule
