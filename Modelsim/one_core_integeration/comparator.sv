timeunit 1ns; timeprecision 100ps;
//`include "alu_codes.sv"  
module comparator #(parameter n =32) (
	input logic [n-1:0] a, b,
	output logic eq,lt,ltu
);

assign eq = a == b;
assign lt = $signed(a) < $signed(b);
assign ltu = a < b;

endmodule
