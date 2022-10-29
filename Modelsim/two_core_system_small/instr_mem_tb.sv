timeunit 1ns; timeprecision 100ps;

module instr_mem_tb;

parameter Isize = 32; 
parameter mem_size = 10;

logic [Isize-1:0] address;
logic [Isize-1:0] instruction;

instr_mem #(.Isize(Isize),.mem_size(mem_size)) instrm1(.*);

initial begin

address = 0;
#10
$display("Current INstruction = %b", instruction);

address = 4;
#10
$display("Current INstruction = %b", instruction);

address = 8;
#10
$display("Current INstruction = %b", instruction);


$stop;
end

endmodule