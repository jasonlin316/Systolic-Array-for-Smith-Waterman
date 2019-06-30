`timescale 1ns/10ps
//`define SDFFILE    "syn/SET_syn.sdf"    // Modify your sdf file name here
`define cycle 14.2
`define terminate_cycle 111950000 // Modify your terminate ycle here
`define SDFFILE    "core_syn.sdf"

module testfixture;

`ifdef SDF
	initial $sdf_annotate(`SDFFILE, u_set);
`endif

`define input_pattern "../../dat/BinaryInput.dat"
`define input_size "../../dat/data_size.dat"
`define golden "../../dat/out_1.dat"

reg clk = 0;
reg rst;

reg [2:0] s_signal;
reg [2:0] t_signal;
reg	[15:0] s_len;
reg [15:0] t_len;
reg	[15:0] s_len_o;
reg [15:0] t_len_o;
wire		t_valid;
wire busy;
wire valid;
wire [15:0] max_out;

integer err_cnt;
integer iteration;
parameter N = 64;
parameter logN = 6;


reg [8651:0] pat_mem [0:19];
reg [15:0] size_mem [0:19];
reg [20:0] expected_mem[0:19];


initial begin
   $fsdbDumpfile("SET_gatelevel.fsdb");
   $fsdbDumpvars;
   $fsdbDumpMDA;
   //$dumpfile("SW.vcd");
   //$dumpvars(0,testfixture); 
end

initial begin
	$timeformat(-9, 1, " ns", 9); //Display time in nanoseconds
	$readmemb(`input_pattern, pat_mem);
	$readmemh(`input_size, size_mem);
	$readmemh(`golden,expected_mem);
	$display("--------------------------- [ Simulation Starts !! ] ---------------------------");

end

always #(`cycle/2) clk = ~clk;


core u_set( 
	.clk(clk),
	.reset_i(rst),
	.S(s_signal),
	.T(t_signal), 
	.s_len_i(s_len_o), 
	.t_len_i(t_len_o), 
	.busy(busy), 
	.valid(valid), 
	.max_out(max_out),
	.t_valid_in(t_valid)
	);

integer k;
integer p;
integer r;
integer g;
integer c = 0;
integer d = 0;
integer v;
integer x;
integer lower;

initial begin
	s_len_o = 0;
	t_len_o = 0;
	s_signal = 0;
	t_signal = 0;

     	rst = 0;
# `cycle;     
	rst = 1;
#(`cycle*3);
	rst = 0;

	for (k = 0; k < 20; k = k+2) begin
	
	@(negedge clk);

			t_len = size_mem[k+1];
			s_len = size_mem[k];
			c = (s_len*3-1);
			d = (t_len*3-1);
			
			if((s_len > 16'd1024) && (t_len > 16'd1024))begin
				$display("Sequences are too long to handle.");
				$finish;
			end
			if(((s_len > 16'd1024) && (t_len <= 16'd1024)) || ((t_len > 16'd1024) && (s_len <= 16'd1024)) )begin
				//The longer sequence becomes s.
				
					if(s_len >= t_len)begin
						s_len_o = (s_len + 16'd2);
						t_len_o = (t_len + 16'd2);
						#(`cycle/4)	wait(busy == 0);
						iteration = (s_len >> logN);
						if(s_len[logN-1:0]!=0)iteration = iteration + 1;
						//$display("Situation 1, iteration = %d",iteration);
						for(g=0 ; g<iteration ; g=g+1)begin
							c = (s_len*3);
							v = (c-(3*N));
							lower = (v >= 0)? v : 0 ;
							t_signal = 3'b000;
							#(`cycle/4);
							s_signal = 3'b001;
							if(g==0)#(`cycle*2);
							else #(`cycle);

							for(r = lower; r<c; r= r+3)//todo2
							begin
								s_signal = {pat_mem[k][r+2],pat_mem[k][r+1],pat_mem[k][r]};
								#(`cycle);
							end
							s_signal = 3'b010;
							#(`cycle);
							s_signal = 3'b000;
							
							if(s_len > N)begin
								s_len = s_len - N;
							end
							wait(t_valid == 0);
							t_signal = 3'b001;
							
							#(`cycle*3);
							for(r = d; r>0; r= r-3)
							begin                
								t_signal = {pat_mem[k+1][r],pat_mem[k+1][r-1],pat_mem[k+1][r-2]};
								#(`cycle);
							end
							t_signal = 3'b010;
							#(`cycle);
							t_signal = 3'b000;
							
							wait(valid == 1);
							#(`cycle);
							s_len_o = (s_len + 16'd2);
					end
					wait (valid == 1);
          			//Wait for signal output
					@(negedge clk);
					if (max_out === expected_mem[(k/2)])
						$display(" Pattern %d is passed !Expected candidate = %d, Response candidate = %d", (k/2), expected_mem[(k/2)], max_out);
					else begin
						$display(" Pattern %d failed !. Expected candidate = %d, but the Response candidate = %d !! ", (k/2), expected_mem[(k/2)], max_out);
						err_cnt = err_cnt + 1;
					end
				end 
				else begin//s signal <= pat_mem[k+1]
					s_len_o = (t_len + 16'd2);
					t_len_o = (s_len + 16'd2);
					#(`cycle/4)	wait(busy == 0);
					iteration = (t_len >> logN);
					if(t_len[logN-1:0]!=0)iteration = iteration + 1;
					
					for(g=0 ; g<iteration ; g=g+1)begin
						d = (t_len*3);
						v = (d-(3*N));
						lower = (v >= 0)? v : 0 ;
						t_signal = 3'b000;
						#(`cycle/4);
						s_signal = 3'b001;
						if(g==0)#(`cycle*2);
						else #(`cycle);

						for(r = lower; r < d ;r = r+3)
						begin                
							s_signal = {pat_mem[k+1][r+2],pat_mem[k+1][r+1],pat_mem[k+1][r]};
							#(`cycle);
						end
						s_signal = 3'b010;
						#(`cycle);
						s_signal = 3'b000;
						if(t_len > N)begin
							t_len = t_len - N;
						end
						wait(t_valid == 0);
						t_signal = 3'b001;
						
							#(`cycle*3);
							

						for(r = c; r>0; r= r-3)
						begin
							t_signal = {pat_mem[k][r],pat_mem[k][r-1],pat_mem[k][r-2]};
							#(`cycle);
						end
						t_signal = 3'b010;
							#(`cycle);
						t_signal = 3'b000;
						wait(valid == 1);
						#(`cycle);
						s_len_o = (t_len + 16'd2);	
					end
					wait (valid == 1);
          			//Wait for signal output
					@(negedge clk);
					if (max_out === expected_mem[(k/2)])
						$display(" Pattern %d is passed !Expected candidate = %d, Response candidate = %d", (k/2), expected_mem[(k/2)], max_out);
					else begin
						$display(" Pattern %d failed !. Expected candidate = %d, but the Response candidate = %d !! ", (k/2), expected_mem[(k/2)], max_out);
						err_cnt = err_cnt + 1;
					end
				end
			end 
			else begin
				//The shorter sequence becomes s_signal.
			
				if(s_len >= t_len)begin //s signal <= pat_mem[k+1]
					s_len_o = (t_len + 16'd2);
					t_len_o = (s_len + 16'd2);
					
					#(`cycle/4)	wait(busy == 0);
					
					iteration = (t_len >> logN);
					if(t_len[logN-1:0]!=0)iteration = iteration + 1;
					
					for(g=0 ; g<iteration ; g=g+1)begin
						d = (t_len*3);
						v = (d-(3*N));
						lower = (v >= 0)? v : 0 ;
						
						t_signal = 3'b000;
						#(`cycle/4);
						s_signal = 3'b001;
						if(g==0)#(`cycle*2);
						else #(`cycle);
							
						for(r = lower; r < d ;r = r+3)
						begin                
							s_signal = {pat_mem[k+1][r+2],pat_mem[k+1][r+1],pat_mem[k+1][r]};
							#(`cycle);
						end
						s_signal = 3'b010;
							#(`cycle);
						s_signal = 3'b000;

						if(t_len > N)begin
							t_len = t_len - N;
						end
						wait(t_valid == 0);
					
						t_signal = 3'b001;
							#(`cycle*3);

						for(r = c; r>0; r= r-3)
						begin
							t_signal = {pat_mem[k][r],pat_mem[k][r-1],pat_mem[k][r-2]};
							#(`cycle);
						end
						t_signal = 3'b010;
							#(`cycle);
						t_signal = 3'b000;
						
						wait(valid == 1);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
				
						#(`cycle);
						s_len_o = (t_len + 16'd2);
					end
					
					wait (valid == 1);
					
          			//Wait for signal output
          			@(negedge clk);
					if (max_out === expected_mem[(k/2)])
						$display(" Pattern %d is passed !Expected candidate = %d, Response candidate = %d", (k/2), expected_mem[(k/2)], max_out);
					else begin
						$display(" Pattern %d failed !. Expected candidate = %d, but the Response candidate = %d !! ", (k/2), expected_mem[(k/2)], max_out);
						err_cnt = err_cnt + 1;
					end
				end 
				else begin//s signal <= pat_mem[k]
					s_len_o = (s_len + 16'd2);
					t_len_o = (t_len + 16'd2);
					
					#(`cycle/4)	wait(busy == 0);
				
					iteration = (s_len >> logN);
					if(s_len[logN-1:0]!=0)iteration = iteration + 1;
					//$display("Situation 4, iteration = %d",iteration);
					for(g=0 ; g<iteration ; g=g+1)begin
						
						c = (s_len*3);
						v = (c-(3*N));
						lower = (v >= 0)? v : 0 ;
						
						t_signal = 3'b000;
						#(`cycle/4);
						s_signal = 3'b001;
						if(g==0)#(`cycle*2);
						else #(`cycle);

						for(r = lower; r < c; r = r+3)
						begin
							s_signal = {pat_mem[k][r+2],pat_mem[k][r+1],pat_mem[k][r]};
							#(`cycle);
						end
						

						s_signal = 3'b010;
							#(`cycle);
						s_signal = 3'b000;
						if(s_len > N)begin
							s_len = s_len - N;
						end
						wait(t_valid == 0);
					
						t_signal = 3'b001;
						
							#(`cycle*3);

						for(r = d; r>0; r= r-3)
						begin                
							t_signal = {pat_mem[k+1][r],pat_mem[k+1][r-1],pat_mem[k+1][r-2]};
							#(`cycle);
						end
						t_signal = 3'b010;
							#(`cycle);
						t_signal = 3'b000;
						wait(valid == 1);
						
						#(`cycle);
						s_len_o = (s_len + 16'd2);
					end
					wait (valid == 1);
			
          			//Wait for signal output
          			@(negedge clk);
					if (max_out === expected_mem[(k/2)])
						$display(" Pattern %d is passed !Expected candidate = %d, Response candidate = %d", (k/2), expected_mem[(k/2)], max_out);
					else begin
						$display(" Pattern %d failed !. Expected candidate = %d, but the Response candidate = %d !! ", (k/2), expected_mem[(k/2)], max_out);
						err_cnt = err_cnt + 1;
					end
				end
			end
			#(`cycle*2)
		      	rst = 0;
			# `cycle;     
				rst = 1;
			#(`cycle*3);
				rst = 0;
				
	end
	$display("--------------------------- Simulation Stops !!---------------------------");
     if (err_cnt) begin 
     	$display("============================================================================");
     	$display("\n (T_T) ERROR found!! There are %d errors in total.\n", err_cnt);
        $display("============================================================================");
	end
     else begin 
        $display("============================================================================");
        $display(" \033[1;33m##########\                                  #########\033[m");
        $display("\033[1;33m############/                           #############\033[m");
        $display("  \033[1;33m  (#############       /            ##################\033[m");
        $display("  \033[1;33m  ################################################ \033[m ");
        $display("  \033[1;33m     /###########################################  \033[m   ");
        $display(" \033[1;33m         //(#####################################(  \033[m    ");
        $display("   \033[1;33m        (##################################(/     \033[m    ");
		$display("   \033[1;33m     /####################################(     \033[m    ");
		$display("   \033[1;33m   #####(   /###############(    ########(   \033[m     ");
		$display("   \033[1;33m (#####       ##############     (########  \033[m	   ");
		$display(".  \033[1;33m  #######(  (################   (#########( \033[m	   ");
		$display(".   \033[1;33m/###############/  (######################/	\033[m   ");
		$display("\033[1;35m    .//////\033[m\033[1;33m###########################\033[m\033[1;35m/ ///(\033\033[1;33m###( \033[m	   ");
		$display("\033[1;35m  .//////(\033[m\033[1;33m##########################\033[m\033[1;35m///////\033\033[1;33m######  \033[m	   ");
		$display("\033[1;35m   ./////\033[m \033[1;33m#########(       #########\033[m\033[1;35m(//////\033\033[1;33m####( \033[m    ");
		$display("\033[1;35m   (#((\033[m\033[1;33m###########(        (#########\033[m\033[1;35m(((((\033\033[1;33m######/  \033[m  ");
		$display("  \033[1;33m /###############(      /(####################( \033[m   ");
		$display("   \033[1;33m/#################(  (#######################  \033[m  ");
		$display("\033[1;33m   (###########################################(  \033[m ");
		$display("\033[1;36m	^o^		WOOOOOW  YOU  PASSED!!!\033[m");
        $display("\n");
        $display("============================================================================");
        $finish;
	end
	$finish;
#(`cycle*2);

end


initial begin 
	#`terminate_cycle;
	$display("================================================================================================================");
	$display("(/`n`)/ ~#  There is something wrong with your code!!"); 
	$display("Time out!! The simulation didn't finish after %d cycles!!, Please check it!!!", `terminate_cycle); 
	$display("================================================================================================================");
	$finish;
end

endmodule
