timeunit 1ns; timeprecision 100ps;
module reg_file_tb;

parameter n = 32;

logic clk; 
logic [n-1:0] wdata, pc_plus_four, external_input;
logic [2:0] write_sel; //001 = write_alu, 010 = jal_return, 100 = external
logic [4:0] rs1,rs2,rd;
logic [n-1:0] data1,data2;

reg_file  #(.n(n)) regs1(.*);

initial
begin
  clk =  0;
  #5ns  forever #5ns clk = ~clk;
end

initial begin


write_sel = 3'b001;
rs1 = 3; rs2 = 1; rd = 7;
wdata = 15;

#22 
rs1 = 3; rs2 = 1; rd = 7;
write_sel = 3'b010;
pc_plus_four = 23;

#20
rs1 = 3; rs2 = 1; rd = 7;
write_sel = 3'b100;
external_input	= 12;


#30 $stop;
end

initial begin
$monitor("Reg %d contains data1 = %d, Reg %d contains data2 = %d", rs1,rs2,addr2,data2);
end

endmodule

