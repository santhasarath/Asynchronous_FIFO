
`include "fifo_async.v"
module tb_fifo_async;
parameter SIZE=124;
parameter WIDTH=8;
parameter DEPTH=SIZE/WIDTH;
parameter ADDR_WIDTH=$clog2(DEPTH);
parameter WRITE_TP = 8, READ_TP = 6;

reg wr_clk_i,rd_clk_i,rst_i,wr_valid_i,rd_valid_i;
reg[WIDTH-1:0] wdata_i;
wire full_o,empty_o,wr_error_o,rd_error_o;
wire [WIDTH-1:0] rdata_o;
integer i,j,k,l,delay_wr,delay_rd;
reg [40*8:1] testcase;
fifo_async #(.SIZE(SIZE))dut (full_o,empty_o,rdata_o,wr_error_o,rd_error_o,wr_clk_i,rd_clk_i,rst_i,wdata_i,wr_valid_i,rd_valid_i);

initial begin
	wr_clk_i = 1'b0;
	forever #(WRITE_TP/2) wr_clk_i = ~wr_clk_i;
end
initial begin
	rd_clk_i = 1'b0;
	forever #(READ_TP/2) rd_clk_i = ~rd_clk_i;
end

initial begin
	$value$plusargs("testcase=%s",testcase);
	rst_i=1'b1;
	wr_valid_i = 0;
	rd_valid_i = 0;
	wdata_i = 0;
	@(posedge wr_clk_i);
	@(posedge wr_clk_i);
	rst_i = 1'b0;
	case (testcase)
	 "fifo_full":begin
	              write_data (DEPTH);
				  end
	 "fifo_empty":begin
					write_data (DEPTH);
					read_data (DEPTH);
	 		     end
	"fifo_write_error":begin
	    			 	write_data (DEPTH+1);
						end
	"fifo_read_error":begin
						write_data (DEPTH);
						read_data (DEPTH+1);
					   end
	"fifo_concurrent_wr_rd_nodelay":begin
						fork
						write_data (DEPTH);
					    read_data (DEPTH+1);
						 join
						   		    end
	"fifo_concurrent_wr_rd_delay":begin
				 fork
				 	for(k=0;k<DEPTH;k=k+1) begin
					  write_data (1);
					  delay_wr = $urandom_range (1,5);
		              repeat (delay_wr) @(posedge wr_clk_i);
			 	  	 end
			    	  for (l=0;l<DEPTH;l=l+1) begin
					    read_data (1);
					    delay_rd = $urandom_range (1,9);
		   			   repeat (delay_rd) @(posedge rd_clk_i);
					   end
					join
					end
endcase

	@(posedge wr_clk_i);
	@(posedge wr_clk_i);
    $finish; 
end

task write_data (input integer loc_size);
	begin
		for (i=0;i<=loc_size-1;i=i+1) begin
			@(posedge wr_clk_i);
			wr_valid_i =1;
			wdata_i = $random;
		end
		@(posedge wr_clk_i)
		wr_valid_i = 0;
		wdata_i = 0;
	end
endtask
task read_data (input integer loc_size);
	begin
		for (j=0;j<=loc_size-1;j=j+1) begin
			@(posedge rd_clk_i);
			rd_valid_i =1;
		end
		@(posedge rd_clk_i)
		rd_valid_i = 0;
	end
endtask
endmodule
