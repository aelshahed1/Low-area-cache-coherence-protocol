timeunit 1ns; timeprecision 100ps;
`include "alu_codes.sv"  
module alu #(parameter n =32) (
   input logic [n-1:0] a, b, // ALU operands
   input logic [3:0] func, // ALU function code
   //output logic Z_flag,
   output logic [n-1:0] result // ALU result
); 

logic[n-1:0] b2,ar; // temp signals
logic[2*n-1:0] product;

always_comb
begin
	b2 = ~b + 1'b1; //2's complement values
   if(func==`FSUB)
		ar = a+b2; // subtraction 
	else
		ar = a+b;
   
   product = a*b;
end

always_comb
begin
  //default output values; prevent latches 
  result = 32'd0; // default
  //Z_flag = 1'b0; //default
  unique case(func)
  	`FNONE : result = 32'd0;
	`FADD  : result = ar; // arithmetic addition
    `FSUB  : result = ar; // arithmetic subtraction
	`FMULT : result = product[n-1:0];
	`FMULTH : result = product[2*n-1:n];	 
	`FAND   : result = a & b;	
	`FOR   : result = a | b;
	`FXOR   : result = a ^ b;
	`FSLL   : result = a<<b[4:0];
	`FSRL   : result = a>>b[4:0];
	`FSRA   : result = a>>>b[4:0];
	`FSLT   : result = { {(n-1){1'b0}} , ($signed(a)<$signed(b))};
	`FSLTU  : result = { {(n-1){1'b0}} , (a<b)};
	 
	 default: result = 32'd0;	
	endcase
	
	//Z_flag = result == {n{1'b0}};
	
end

endmodule