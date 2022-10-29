timeunit 1ns; timeprecision 100ps;
 
module comparator_tb;

parameter n =32;

logic [n-1:0] a, b;
logic eq,lt,ltu;

comparator #(.n(n)) comp1(.*);

initial begin

a = 5;
b = 10;
#10 $display("for a = %d and b = %d, equal flag = %b and less lt flag = %b and ltu flag = %b", a,b,eq,lt,ltu);

a = 5;
b = 5;
#10 $display("for a = %d and b = %d, equal flag = %b and less lt flag = %b and ltu flag = %b", a,b,eq,lt,ltu);

a = 5;
b = 32'hffffffff;
#10 $display("for a = %d and b = %d, equal flag = %b and less lt flag = %b and ltu flag = %b", a,b,eq,lt,ltu);

$stop;
end

endmodule