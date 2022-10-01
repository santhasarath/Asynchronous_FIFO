
module fifo_async (full_o,empty_o,rdata_o,wr_error_o,rd_error_o,wr_clk_i,rd_clk_i,rst_i,wdata_i,wr_valid_i,rd_valid_i);
parameter SIZE=128;
parameter WIDTH=8;
parameter DEPTH=SIZE/WIDTH;
parameter ADDR_WIDTH=$clog2(DEPTH);

input wr_clk_i,rd_clk_i,rst_i,wr_valid_i,rd_valid_i;
input[WIDTH-1:0] wdata_i;
output reg full_o,empty_o,wr_error_o,rd_error_o;
output reg[WIDTH-1:0] rdata_o;

reg [WIDTH-1:0] memory [DEPTH-1:0];
reg [ADDR_WIDTH-1:0] wr_ptr,rd_ptr;
reg [ADDR_WIDTH-1:0] wr_ptr_gray,rd_ptr_gray;
reg [ADDR_WIDTH-1:0] wr_ptr_gray_rd_clk,rd_ptr_gray_wr_clk;
reg wr_toggle,rd_toggle;
reg wr_toggle_rd_clk,rd_toggle_wr_clk;
integer i;

always @ (posedge wr_clk_i) begin
	if (rst_i==1) begin              //reset 
		full_o = 1'b0;
		empty_o =1'b1;
		rdata_o = 0;
		wr_ptr =0;
		rd_ptr = 0;
		wr_ptr_gray = 0;
		rd_ptr_gray = 0;
		wr_ptr_gray_rd_clk = 0;
		rd_ptr_gray_wr_clk = 0;
		wr_toggle=0;
		rd_toggle=0;
		wr_toggle_rd_clk=0;
		rd_toggle_wr_clk=0;
		wr_error_o=0;
		rd_error_o=0;
		for (i=0;i<DEPTH;i=i+1) begin
			memory[i] = 0;
		end
	end

	else begin           //fifo structure
		if (full_o == 0) begin
			wr_error_o =0;
			if (wr_valid_i==1) begin
				memory[wr_ptr] = wdata_i;
				if (wr_ptr == DEPTH-1) begin
					wr_ptr = wr_ptr+1;
					wr_toggle = ~wr_toggle;
				end
			 	else begin
						wr_ptr = wr_ptr+1;
			 	end
				wr_ptr_gray = {wr_ptr[ADDR_WIDTH-1],wr_ptr[ADDR_WIDTH-1:1]^wr_ptr[ADDR_WIDTH-2:0]};
			 end
		end
		else wr_error_o = 1;
	end
end

always @ (posedge rd_clk_i) begin
		
		if (empty_o == 0) begin
			rd_error_o = 0;
			if (rd_valid_i==1) begin
				rdata_o=memory[rd_ptr];
				if (rd_ptr == DEPTH-1) begin
					rd_ptr = rd_ptr+1;
					rd_toggle = ~rd_toggle;
				end
				else begin
					rd_ptr = rd_ptr+1;
				end
				rd_ptr_gray = {rd_ptr[ADDR_WIDTH-1],rd_ptr[ADDR_WIDTH-1:1]^rd_ptr[ADDR_WIDTH-2:0]};
			end
		end
		else rd_error_o = 1;
end
always @ (posedge wr_clk_i) begin
	rd_toggle_wr_clk <= rd_toggle;
	rd_ptr_gray_wr_clk <= rd_ptr_gray;
end
always @ (posedge rd_clk_i) begin
	wr_toggle_rd_clk <= wr_toggle;
	wr_ptr_gray_rd_clk <= wr_ptr_gray;
end
always @ (*) begin   //full and empty condition
	full_o = 1'b0;
	empty_o = 1'b0;
	if (wr_ptr_gray_rd_clk == rd_ptr_gray && wr_toggle_rd_clk ==rd_toggle) empty_o =1;
	if (wr_ptr_gray == rd_ptr_gray_wr_clk && wr_toggle !=rd_toggle_wr_clk) full_o =1;
end

endmodule
