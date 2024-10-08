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




module test_MEM;

reg [63:0] addr , Data_In;
reg WR , clk=0;
wire [63:0] Data_Out;

MEM mem(addr , Data_In , Data_Out , WR , clk);
always #2 clk <= ~clk;
initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
$monitor("WR = %b , Data_In = %d , addr = %d , Data_Out = %d",WR,Data_In
        ,addr,Data_Out);

$display("Do Nothing : ");
WR = 0;
Data_In = 0; addr = 0; #4;
Data_In = 1; addr = 1; #4;
Data_In = 2; addr = 2; #4;
Data_In = 3; addr = 3; #4;
Data_In = 4; addr = 4; #4;
Data_In = 5; addr = 5; #4;
Data_In = 6; addr = 6; #4;

$display("Reading Data : ");
WR = 0;
Data_In = 0; addr = 0; #4;
Data_In = 1; addr = 1; #4;
Data_In = 2; addr = 2; #4;
Data_In = 3; addr = 3; #4;
Data_In = 4; addr = 4; #4;
Data_In = 5; addr = 5; #4;
Data_In = 6; addr = 6; #4;

$display("Writing Data : ");
WR = 1;
Data_In = 0; addr = 0; #4;
Data_In = 1; addr = 1; #4;
Data_In = 2; addr = 2; #4;
Data_In = 3; addr = 3; #4;
Data_In = 4; addr = 4; #4;
Data_In = 5; addr = 5; #4;
Data_In = 6; addr = 6; #4;

$display("Reading Written Data : ");
WR = 0;
Data_In = 0; addr = 0; #4;
Data_In = 1; addr = 1; #4;
Data_In = 2; addr = 2; #4;
Data_In = 3; addr = 3; #4;
Data_In = 4; addr = 4; #4;
Data_In = 5; addr = 5; #4;
Data_In = 6; addr = 6; #4;

$finish;
end


endmodule
