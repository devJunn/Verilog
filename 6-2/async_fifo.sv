module async_fifo #(		
	parameter	DEPTH=8,
	parameter	WIDTH=8,
  	parameter	DEPTH_LOG=$clog2(DEPTH)
)(
	input           	rstn,
	// WCLK DOMAIN
	input           	wclk,	
	input           	push,	
	input [WIDTH-1:0] 	din,
	output          	full,
	// RCLK DOMAIN
	input           	rclk,
	input           	pop,
	output [WIDTH-1:0] 	dout,	
	output          	empty
);

	reg  [WIDTH-1:0] 	mem [DEPTH-1:0];
	
	// WCLK DOMAIN
	reg  [DEPTH_LOG:0] 	wptr_bin;       
	wire [DEPTH_LOG:0] 	wptr_gray;       
	reg  [DEPTH_LOG:0] 	rptr_gray_meta, rptr_gray_wclk; 
	
	// RCLK DOMAIN
	reg  [DEPTH_LOG:0] 	rptr_bin;        
	wire [DEPTH_LOG:0] 	rptr_gray;   
	reg  [DEPTH_LOG:0] 	wptr_gray_meta, wptr_gray_rclk; 
	
	// WCLK DOMAIN
	always @(posedge wclk or negedge rstn)
	if 		(!rstn)	for (int i=0;i<DEPTH;i++)	  mem[i] <= 0;		
	else if (push & ~full)	mem[wptr_bin[DEPTH_LOG-1:0]] <= din;
	
	
	always @(posedge wclk or negedge rstn)
	if 		(!rstn)			wptr_bin	<= 0;
	else if (push & ~full)	wptr_bin 	<= wptr_bin + 1;         
	
	assign wptr_gray 		= bin2gray(wptr_bin);	
	
	always @(posedge wclk or negedge rstn)
	if 		(!rstn)	begin
         rptr_gray_meta <= 0;
         rptr_gray_wclk <= 0;
    end else 		begin
         rptr_gray_meta <= rptr_gray;
         rptr_gray_wclk <= rptr_gray_meta;	//synchronizer
    end   		
	//GRAY STYLE
	assign full   = (wptr_gray[DEPTH_LOG-:2]  == ~rptr_gray_wclk[DEPTH_LOG-:2] ) &&
				    (wptr_gray[DEPTH_LOG-2:0] == rptr_gray_wclk[DEPTH_LOG-2:0]);			

	// RCLK DOMAIN
	always @(posedge rclk or negedge rstn)
	if 		(!rstn)			rptr_bin <= 0;
	else if (pop & ~empty)	rptr_bin <= rptr_bin + 1;
	
	assign rptr_gray 		= bin2gray(rptr_bin);		
	
	always @(posedge rclk or negedge rstn)
	if 		(!rstn)	begin
		wptr_gray_meta  <= 0;
		wptr_gray_rclk  <= 0;
	end else		begin
		wptr_gray_meta <= wptr_gray;
		wptr_gray_rclk <= wptr_gray_meta;
	end
	//GRAY STYLE
	assign empty	= (rptr_gray == wptr_gray_rclk);
	
	//This will be read when data is stable enough
	assign dout = mem[rptr_bin[DEPTH_LOG-1:0]];
	
	function [DEPTH_LOG:0] bin2gray ;
		input  [DEPTH_LOG:0] bin;
		begin
			bin2gray = (bin>>1) ^ bin;
		end
	endfunction
		
endmodule