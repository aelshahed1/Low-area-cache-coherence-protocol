timeunit 1ns; timeprecision 100ps;
module system_tb;

//variables for collecting data
int file,core_A_instructions_file,core_B_instructions_file;
integer SW1 = 0,SW2 = 0,LW1 = 0,LW2 = 0,SW_TOTAL = 0,LW_TOTAL = 0;
integer core_A_total_instructions = 0, core_B_total_instructions = 0,System_total_instructions;
//int simulation_ID;


parameter n = 32;
logic clk, reset;
logic [31:0] L1A_statistics,L1B_statistics,L2_statistics; // hit/miss statistics from caches
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
/*
$monitor("at time %d, core A at instruction %h, core B at instruction %h",
$time,my_system.riscv_core_A.instruction,my_system.riscv_core_B.instruction);
//$monitor("core A at instruction %h",my_system.riscv_core_A.instruction);
*/
$monitor("at time %d, L1A_hit_rate = %.3f, L1B_hit_rate = %.3f,L2_hit_rate = %.3f",$time,
L1A_hit_rate,L1B_hit_rate,L2_hit_rate);
end

initial begin //opening files to write results
//simulation_ID =  $system("date");
file = $fopen("Vsim_output/Results.csv","a+");
if(!file)
	$display("failed to open results file");
else begin
	$display("successfully opened results file");
	$fwrite(file,"\n\n new run, core A: Simple add function,  core B: Simple subtraction function\n");
	//$fwrite(file,"unique data and time = %s\n", simulation_ID); 
	$fwrite(file,"system_elapsed_time(ns),LA1_RH,LA_RM,LA1_WH,LA1_WM,L1A_hit_rate,L1B_RH,L1B_RM,L1B_WH,L1B_WM,L1B_hit_rate,L2_RH,L2_RM,L2_WH,L2_WM,L2_hit_rate,CoreA_SWs,CoreA_LWs,CorB_SWs,CoreB_LWs,Total_SWs,Total_LWs,CoreA_total_instructions,CoreB_total_instructions,System_total_instructions,\n");
end	

core_A_instructions_file = $fopen("Vsim_output/CoreA_instructions_excution_times.csv","a+");
if(!core_A_instructions_file)
	$display("failed to open core A instructions times file");
else begin
	$display("successfully opened core A instructions times file");
	$fwrite(core_A_instructions_file,"\n\n new run, core A: Simple add function,  core B: Simple subtraction function\n");
	//$fwrite(core_A_instructions_file,"unique data and time = %s\n", simulation_ID); 
	$fwrite(core_A_instructions_file,"full_instruction,opcode,current_time(ns),hit_miss_type");
end

core_B_instructions_file = $fopen("Vsim_output/CoreB_instructions_excution_times.csv","a+");
if(!core_B_instructions_file)
	$display("failed to open core B instructions times file");
else begin
	$display("successfully opened core B instructions times file");
	$fwrite(core_B_instructions_file,"\n\n new run, core A: Simple add function,  core B: Simple subtraction function\n");
	//$fwrite(core_B_instructions_file,"unique data and time = %s\n", simulation_ID); 
	$fwrite(core_B_instructions_file,"full_instruction,opcode,current_time(ns),hit_miss_type");
end	
	
end

initial begin

#27
	
	forever begin
			#5
		    if(my_system.riscv_core_A.instruction == 32'h0000006f &&
			(my_system.riscv_core_B.instruction == 32'h0000006f || my_system.riscv_core_B.instruction == 32'h00000013) ) begin
				$display("END OF PROGRAM"); 
				$display("program_done signal = %b",program_done);
				//writing results to files
				$fwrite(file,"%d,%d,%d,%d,%d,%.3f,%d,%d,%d,%d,%.3f,%d,%d,%d,%d,%.3f,",$time,
				my_system.L1A_cache_memory.read_hit_counter,my_system.L1A_cache_memory.read_miss_counter,
				my_system.L1A_cache_memory.write_hit_counter,my_system.L1A_cache_memory.write_miss_counter,
				L1A_hit_rate,
				my_system.L1B_cache_memory.read_hit_counter,my_system.L1B_cache_memory.read_miss_counter,
				my_system.L1B_cache_memory.write_hit_counter,my_system.L1B_cache_memory.write_miss_counter,
				L1B_hit_rate,
				my_system.L2_cache_memory.read_hit_counter,my_system.L2_cache_memory.read_miss_counter,
				my_system.L2_cache_memory.write_hit_counter,my_system.L2_cache_memory.write_miss_counter,
				L2_hit_rate);
				$fwrite(file,"%d,%d,%d,%d,%d,%d,%d,%d,%d",SW1,LW1,SW2,LW2,SW_TOTAL,LW_TOTAL,
				core_A_total_instructions,core_B_total_instructions,System_total_instructions);
				$fwrite(file,"\nReached end of program");
				$fwrite(core_A_instructions_file,"\nReached end of program");
				$fwrite(core_B_instructions_file,"\nReached end of program");
				$fclose(file);
				$fclose(core_A_instructions_file);
				$fclose(core_B_instructions_file);				
				$display("Final Statistics: ");
				$display("program elapsed time = %d ns", $time);
				$display("L1A RH = %d, L1A RM= %d, L1A WH = %d, L1A WM= %d ", 
				my_system.L1A_cache_memory.read_hit_counter,my_system.L1A_cache_memory.read_miss_counter,
				my_system.L1A_cache_memory.write_hit_counter,my_system.L1A_cache_memory.write_miss_counter);
				$display("L1A_hit_rate = %.3f", L1A_hit_rate);
				$display("L1B RH = %d, L1B RM= %d, L1B WH = %d, L1B WM= %d ", 
				my_system.L1B_cache_memory.read_hit_counter,my_system.L1B_cache_memory.read_miss_counter,
				my_system.L1B_cache_memory.write_hit_counter,my_system.L1B_cache_memory.write_miss_counter);
				$display("L1B_hit_rate = %.3f", L1B_hit_rate);
				$display("L2 RH = %d, L2 RM= %d, L2 WH = %d, L2 WM= %d ", 
				my_system.L2_cache_memory.read_hit_counter,my_system.L2_cache_memory.read_miss_counter,
				my_system.L2_cache_memory.write_hit_counter,my_system.L2_cache_memory.write_miss_counter);
				$display("L2_hit_rate = %.3f", L2_hit_rate);
				$display("Core A: SW_instructions = %d, LW_instructions = %d", SW1,LW1);
				$display("Core B: SW_instructions = %d, LW_instructions = %d", SW2,LW2);
				$display("total SW instructions = %d, total LW instructions = %d",SW_TOTAL,LW_TOTAL);
				$display("Core A: TOTAL instructions = %d, Core B: TOTAL instructions = %d", 
				core_A_total_instructions,core_B_total_instructions);
				$display("System total instructions = %d", System_total_instructions);
				$stop;
			end	
	end
end		

real L1A_hit_rate, L1B_hit_rate, L2_hit_rate;

always_comb begin //hit and miss ratios calcualtions
L1A_hit_rate = (real'(my_system.L1A_cache_memory.read_hit_counter) + real'(my_system.L1A_cache_memory.write_hit_counter)) /
(real'(my_system.L1A_cache_memory.read_hit_counter) + real'(my_system.L1A_cache_memory.read_miss_counter) +
real'(my_system.L1A_cache_memory.write_hit_counter) + real'(my_system.L1A_cache_memory.write_miss_counter));

L1B_hit_rate = (real'(my_system.L1B_cache_memory.read_hit_counter) + real'(my_system.L1B_cache_memory.write_hit_counter)) /
(real'(my_system.L1B_cache_memory.read_hit_counter) + real'(my_system.L1B_cache_memory.read_miss_counter) +
real'(my_system.L1B_cache_memory.write_hit_counter) + real'(my_system.L1B_cache_memory.write_miss_counter));

L2_hit_rate = (real'(my_system.L2_cache_memory.read_hit_counter) + real'(my_system.L2_cache_memory.write_hit_counter)) /
(real'(my_system.L2_cache_memory.read_hit_counter) + real'(my_system.L2_cache_memory.read_miss_counter) +
real'(my_system.L2_cache_memory.write_hit_counter) + real'(my_system.L2_cache_memory.write_miss_counter));
end

always_comb begin  //hit miss statistics for L1A
	$strobe("LA1 RH = %d, LA1 RM= %d, LA1 WH = %d, LA1 WM= %d ", 
	my_system.L1A_cache_memory.read_hit_counter,my_system.L1A_cache_memory.read_miss_counter,
	my_system.L1A_cache_memory.write_hit_counter,my_system.L1A_cache_memory.write_miss_counter);
end

always_comb begin //hit miss statistics for L1B
	$strobe("LB1 RH = %d, LB1 RM= %d, LB1 WH = %d, LB1 WM= %d ", 
	my_system.L1B_cache_memory.read_hit_counter,my_system.L1B_cache_memory.read_miss_counter,
	my_system.L1B_cache_memory.write_hit_counter,my_system.L1B_cache_memory.write_miss_counter);
end

always_comb begin //hit miss statistics for L2
	$strobe("L2 RH = %d, L2 RM= %d, L2 WH = %d, L2 WM= %d ", 
	my_system.L2_cache_memory.read_hit_counter,my_system.L2_cache_memory.read_miss_counter,
	my_system.L2_cache_memory.write_hit_counter,my_system.L2_cache_memory.write_miss_counter);
end

always @(posedge clk) begin  //CORE A SW AND LW counters
	if($changed(my_system.riscv_core_A.instruction)) begin
		core_A_total_instructions = core_A_total_instructions + 1;
		$fwrite(core_A_instructions_file,"\n%h,%b,%d,",
		my_system.riscv_core_A.instruction,my_system.riscv_core_A.instruction[6:0],$time);
		if(my_system.riscv_core_A.instruction[6:0] == 7'b0100011)
			SW1 =SW1 + 1; 
		if(my_system.riscv_core_A.instruction[6:0] == 7'b0000011)	
			LW1 = LW1 + 1;
	end		
end

always @(posedge clk) begin //CORE B SW AND LW counters
	if($changed(my_system.riscv_core_B.instruction)) begin
		core_B_total_instructions = core_B_total_instructions + 1;
		$fwrite(core_B_instructions_file,"\n%h,%b,%d,",
		my_system.riscv_core_B.instruction,my_system.riscv_core_B.instruction[6:0],$time);
		if(my_system.riscv_core_B.instruction[6:0] == 7'b0100011)
			SW2 =SW2 + 1; 
		if(my_system.riscv_core_B.instruction[6:0] == 7'b0000011)	
			LW2 = LW2 + 1;
	end		
end

always_comb begin //counting total load and store instructions
SW_TOTAL = SW1 + SW2;
LW_TOTAL = LW1 + LW2;
System_total_instructions = core_A_total_instructions + core_B_total_instructions;
end


//detecting core A hit/misses
always @(posedge clk) begin
	if(my_system.L1A_cache_memory.read_hit_counter == ($past(my_system.L1A_cache_memory.read_hit_counter) + 1))
			$fwrite(core_A_instructions_file,"read hit");
	else if(my_system.L1A_cache_memory.read_miss_counter == ($past(my_system.L1A_cache_memory.read_miss_counter) + 1))		
			$fwrite(core_A_instructions_file,"read miss");
	else if(my_system.L1A_cache_memory.write_hit_counter == ($past(my_system.L1A_cache_memory.write_hit_counter) + 1))		
			$fwrite(core_A_instructions_file,"write hit");
	else if(my_system.L1A_cache_memory.write_miss_counter == ($past(my_system.L1A_cache_memory.write_miss_counter) + 1))		
			$fwrite(core_A_instructions_file,"write miss");		
end

//detecting core B hit/misses
always @(posedge clk) begin
	if(my_system.L1B_cache_memory.read_hit_counter == ($past(my_system.L1B_cache_memory.read_hit_counter) + 1))
			$fwrite(core_B_instructions_file,"read hit");
	else if(my_system.L1B_cache_memory.read_miss_counter == ($past(my_system.L1B_cache_memory.read_miss_counter) + 1))		
			$fwrite(core_B_instructions_file,"read miss");
	else if(my_system.L1B_cache_memory.write_hit_counter == ($past(my_system.L1B_cache_memory.write_hit_counter) + 1))		
			$fwrite(core_B_instructions_file,"write hit");
	else if(my_system.L1B_cache_memory.write_miss_counter == ($past(my_system.L1B_cache_memory.write_miss_counter) + 1))		
			$fwrite(core_B_instructions_file,"write miss");		
end

endmodule