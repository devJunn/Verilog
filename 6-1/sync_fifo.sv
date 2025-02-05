module sync_fifo #(
	parameter	DEPTH=8,
	parameter	WIDTH=32,	
	parameter	AF_LEVEL = 1,
	parameter	AE_LEVEL = 1,
  	parameter	DEPTH_LOG=$clog2(DEPTH)
)(
	input					clk, rstn,
	input					push, pop,	
	input 		[WIDTH-1:0]	din,
	output 		[WIDTH-1:0]	dout,
	output					full,empty,a_full,a_empty
);
	reg [WIDTH-1:0]		mem[DEPTH-1:0];
	reg [DEPTH_LOG-1:0]	wr_ptr, rd_ptr;
	reg [DEPTH_LOG  :0] diff_ptr;
	
	always @(posedge clk, negedge rstn)
	if	(!rstn)	begin
		for (int i=0;i<DEPTH;i++)	mem[i] = 0;
	end else if (push) begin
		mem[wr_ptr]	<= din;
	end
	
	always @(posedge clk, negedge rstn)
	if		(!rstn)	wr_ptr	<= 0;
	else if (push)	wr_ptr	<= wr_ptr + 1;
	
	always @(posedge clk, negedge rstn)
	if		(!rstn)	rd_ptr	<= 0;
	else if (pop)	rd_ptr	<= rd_ptr + 1;
	
	assign dout = mem[rd_ptr];
		
	always @(posedge clk, negedge rstn)
	if		(!rstn)	diff_ptr <= 0;
	else			diff_ptr <= diff_ptr + push - pop;	
	
	assign	full 	= diff_ptr >= DEPTH;
	assign	a_full	= diff_ptr >= DEPTH - AF_LEVEL;
	assign	empty	= diff_ptr == 0;
	assign	a_empty = diff_ptr <= AE_LEVEL;	
	
endmodule