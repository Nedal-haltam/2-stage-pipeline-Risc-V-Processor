module Branch_CondGen(Rs1 , Rs2 , eq , lt , ltu);///////////////////////////////

input [63:0] Rs1 , Rs2;
output reg eq , lt , ltu;


always@(Rs1 or Rs2) begin

eq = (Rs1 == Rs2) ? 1'b1 : 1'b0;

lt = ($signed(Rs1) < $signed(Rs2)) ? 1'b1 : 1'b0;

ltu = (Rs1 < Rs2) ? 1'b1 : 1'b0;

end

endmodule



module test_branchCodeGen;

reg [63:0] rs1 , rs2;
wire eq , lt , ltu;

Branch_CondGen bcg(rs1, rs2, eq, lt, ltu);
// I used these variables to display the values in the signed representation (testing purposes)
reg signed [63:0] srs1 , srs2;
initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
$monitor("Rs1 = %d , Rs2 = %d , Rs1(signed) = %d , Rs2(signed) = %d , eq = %b , lt = %b , ltu = %b",rs1,rs2,srs1,srs2,eq,lt,ltu);


rs1 = 0;   rs2 = 0;    srs1 = $signed(rs1); srs2 = $signed(rs2); #1;
rs1 = 1;   rs2 = 10;   srs1 = $signed(rs1); srs2 = $signed(rs2); #1;
rs1 = 123; rs2 = 321;  srs1 = $signed(rs1); srs2 = $signed(rs2); #1;
rs1 = -1;  rs2 = 1;    srs1 = $signed(rs1); srs2 = $signed(rs2); #1;
rs1 = -1;  rs2 = -1;   srs1 = $signed(rs1); srs2 = $signed(rs2); #1;
rs1 = -10; rs2 = -12;  srs1 = $signed(rs1); srs2 = $signed(rs2); #1;
rs1 = -5;  rs2 = -15;  srs1 = $signed(rs1); srs2 = $signed(rs2); #1;
rs1 = 10;  rs2 = -10;  srs1 = $signed(rs1); srs2 = $signed(rs2); #1;
rs1 = -10; rs2 = 10;   srs1 = $signed(rs1); srs2 = $signed(rs2); #1;

end
endmodule
