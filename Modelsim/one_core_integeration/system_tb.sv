timeunit 1ns; timeprecision 100ps;
module system_tb;

parameter n = 32;

logic clk, reset;
logic program_done; //program done led

system #(.n(n)) my_system(.*);

initial begin
	clk = '0;
	#5ns reset = '0;
	#5ns reset = '1;
	#5ns reset = '0;
	forever #5ns clk = ~clk;
end	

initial begin

#27
	
	forever begin
			#5
		    if(my_system.riscv_core.instruction === 32'hxxxxxxxx) begin
				#20 $display("END OF PROGRAM"); 
				//for(int i=0;i<32;i=i+1) 
					//$display("value at reg %d = %d",i,riscv.regs.gpr[i]);
				$display("program_done signal = %b",program_done);
				$display("program elapsed time = %d ns", $time);
				$stop;
			end	
	end
end		


//initial begin
//	forever //begin
			//@(my_system.L2_cache_memory.state == 3) $display("in L2 refill, input address = %h",my_system.L2_cache_memory.L1_word_address);
			//#5
			//end
//end

initial begin 
//$monitor("At instruction %h, L1 state = %s, L2 state = %s",my_system.riscv_core.instruction,my_system.L1_cache_memory.state,my_system.L2_cache_memory.state);
//$display(" ");
//$monitor("instruction memory select address is %d, \n%b", riscv.instrMEMORY.address,riscv.instrMEMORY.address);
end

	//if($rose(my_system.L1_cache_memory.load) || $rose(my_system.L1_cache_memory.store))


always_comb begin //print L1 load and store instructions
	///*
	if(my_system.L1_cache_memory.store) begin	
		//$write("STORE instruction %h: ",my_system.riscv_core.instruction);
		$strobe("*L1_STORE: input data = %d, input address =  %d",my_system.L1_cache_memory.dmem_wdata,my_system.L1_cache_memory.dmem_word_address);	
	end
	//*/
	/*
	if(my_system.L1_cache_memory.load && (my_system.L1_cache_memory.state == 6) ) begin	
		//$write("STORE instruction %h: ",my_system.riscv_core.instruction);
		$strobe("*L1_LOAD: output data = %d, input address =  %d",my_system.L1_cache_memory.dmem_rdata,my_system.L1_cache_memory.dmem_word_address);		
	end
	*/
end


always_comb begin //print L2 load and store instructions
	///*
	if(my_system.L2_cache_memory.L1_write_request) begin	
		//$write("STORE instruction %h: ",my_system.riscv_core.instruction);
		$strobe("***L2_STORE: input data = %d, input address =  %d",my_system.L2_cache_memory.L1_wdata,my_system.L2_cache_memory.L1_word_address);	
	end
	//*/
	/*
	if(my_system.L2_cache_memory.L1_read_request) begin	
		//$write("STORE instruction %h: ",my_system.riscv_core.instruction);
		$strobe("***L2_LOAD: output data = %d, input address =  %d",my_system.L2_cache_memory.MM_write_word,my_system.L2_cache_memory.L1_word_address);		
	end
	*/	
end

always_comb begin //print MM load and store instructions
	///*
	if(my_system.my_main_memory.L2_write_request) begin	
		//$write("STORE instruction %h: ",my_system.riscv_core.instruction);
		$strobe("*****MM_STORE: input data = %d, input address =  %d",my_system.my_main_memory.L2_wdata,my_system.my_main_memory.L2_word_address);	
	end
	//*/
	/*
	if(my_system.my_main_memory.L2_read_request) begin	
		//$write("STORE instruction %h: ",my_system.riscv_core.instruction);
		$strobe("******MM_LOAD: output data = %d, input address =  %d",my_system.my_main_memory.L2_rdata,my_system.my_main_memory.L2_word_address);		
	end
	*/	
end

endmodule