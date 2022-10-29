timeunit 1ns; timeprecision 100ps;
`include "alu_codes.sv"  

module alu_tb;

parameter n =32;

logic [n-1:0] a, b; // ALU operands
logic [3:0] func; // ALU function code
logic [n-1:0] result; // ALU result 
//logic Z_flag;

alu #(.n(n)) alu1(.*);

initial begin

func = `FADD;

a = 118;
b = 20;
#10
$display("result of %d + %d = %d", a,b,result);

#10
func = `FSUB;
a = 8;
b= 8;
//b = 32'hfffffffa;
#10
$display("result of %d - %d = %b", a,b,result);
//$display("Z_flag = %b", Z_flag);

#10
func = `FSLL;

a = 8;
b = 2;
#10
$display("result of %d << %d = %b", a,b,result);

#10
func = `FMULT;
//a = 8'b11111100;
a= 5;
b = 2;
//b = 8'b11000000;
#10

$display("result of %d * %d = %b", a,b,result);
$display("64-bit product = %b", alu1.product);

#10
func = `FMULT;
//a = 8'b11111100;
a= 25;
b = 32'b11111111111111111111111111111110;
//b = 8'b11000000;
#10
$display("result of %d * %d = %b", a,b,result);
$display("64-bit product = %b", alu1.product);

#10
func = `FMULTH;
//a = 8'b11111100;
a= 25;
b = 32'b11111111111111111111111111111110;
//b = 8'b11000000;
#10
$display("result of %d * %d = %b", a,b,result);
$display("64-bit product = %b", alu1.product);


#10
func = `FSLT;

a= -2;
b = 5;
#10

$display("result of %d SLT %d = %b", a,b,result);

#10
func = `FSLTU;

a= -2;
b = 5;
#10

$display("result of %d SLTU %d = %b", a,b,result);


#10 $stop;

end 

endmodule