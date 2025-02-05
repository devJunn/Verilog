module tb_async_fifo;
	localparam DEPTH = 8;
	localparam WIDTH = 8;

	reg					rstn;
	
	reg           		wclk;
	reg           		push;
	reg [WIDTH-1:0] 	din;	
	wire          		full;
	
	reg					rclk;
	reg           		pop;
	wire [WIDTH-1:0] 	dout;	
	wire          		empty;
	
	
	initial begin
		wclk	= 0;
		forever #4 wclk = ~wclk;
	end
	
	initial begin
		#1	rclk	= 0;		
		forever #5 rclk = ~rclk;
	end
	
	initial begin
		rstn = 1;
		#20 rstn = 0;
		#30 rstn = 1;
	end

	initial begin
		push <= 0;
		@(posedge rstn);
		@(posedge wclk);
			 
		for (int i=0;i<2*DEPTH;i++) begin
			push <= 1;
			din  <= 'h10 + i;
			@(posedge wclk);
		end
		push <= 0;
		@(posedge wclk);		
	end
	
	initial begin
		pop <= 0;
		@(posedge rstn);
		repeat (10) @(posedge rclk);
			 
		for (int i=0;i<DEPTH+3;i++) begin
			pop <= 1; @(posedge rclk);
			pop <= 0; @(posedge rclk);
		end
		pop <= 0;
		@(posedge rclk);		
		
		repeat (2) @(posedge rclk);
		$finish;
	end

	async_fifo #(
		.DEPTH(DEPTH), .WIDTH(WIDTH)
	) u_async_fifo (
		.rstn 		(rstn),
	
		.wclk   	(wclk),
		.push		(push),
		.din  		(din),			
		.full  		(full),
	
		.rclk   	(rclk),		
		.pop		(pop),
		.dout  		(dout),
		.empty 		(empty)
   );
endmodule