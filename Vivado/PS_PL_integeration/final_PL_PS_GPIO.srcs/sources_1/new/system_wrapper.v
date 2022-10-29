
module system_wrapper(
    input  clk, reset,
output  [31:0] L1A_statistics,L1B_statistics,L2_statistics, // hit/miss statistics from caches
output  program_done
    );
        
    system (.clk(clk),.reset(reset),.L1A_statistics(L1A_statistics),.L1B_statistics(L1B_statistics),.L2_statistics(L2_statistics),.program_done(program_done));
    
endmodule
