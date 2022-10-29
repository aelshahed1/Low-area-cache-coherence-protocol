module L2_controller(
input logic clk,nreset,
input logic [7:0] shared,
output logic flush
);



always_ff @(posedge clk,negedge nreset)
begin
if(~nreset)
	begin
	flush <= 1'b0;
	end
else
	begin
	if(shared > 0)
		flush <= 1'b1;
	else if(flush == 1)
		flush <= 1'b0;
	
	end	
end


endmodule

