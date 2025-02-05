module tb_apb_uart;
	localparam WRITE=1, READ=0;
	
	reg   			clk, rstn;
	
	reg   [31:0] 	paddr;
	reg          	penable, pwrite;
	reg	  [31:0] 	pwdata;	
	reg				psel_0;
	wire            pready_0, pslverr_0;	
	wire  [31:0] 	prdata_0;
	reg				psel_1;
	wire            pready_1, pslverr_1;	
	wire  [31:0] 	prdata_1;
	
	wire	ser_0_to_1, ser_1_to_0;
	
	initial begin
		clk	= 0;
		forever #5 clk = ~clk;
	end

	initial begin
		rstn = 1;
		#20 rstn = 0;
		#30 rstn = 1;
	end

	initial begin
		{penable,psel_0,psel_1,pwrite} <= 0;
		@(posedge rstn);
		repeat (2) @(posedge clk);
		apb_req (WRITE, 'h04, 'h12);	
		apb_req (WRITE, 'h14, 'h34);
		apb_req (WRITE, 'h00, 'h1);	
		apb_req (WRITE, 'h10, 'h1);
		
		apb_req (READ,'h00,0); 
		while (prdata_0 == 1) begin
			apb_req (READ,'h00,0); 
			repeat (16) @(posedge clk);
		end
		
		apb_req (WRITE, 'h04, 'h56);	
		apb_req (WRITE, 'h14, 'h78);
		apb_req (WRITE, 'h00, 'h1);	
		apb_req (WRITE, 'h10, 'h1);
		
		apb_req (READ,'h08,0); 
		while (prdata_0 == 0) begin
			apb_req (READ,'h08,0); 
			repeat (16) @(posedge clk);
		end
		apb_req (READ,'h0C,0);
		apb_req (READ,'h1C,0);
		
		apb_req (READ,'h08,0); 
		while (prdata_0 == 0) begin
			apb_req (READ,'h08,0); 
			repeat (16) @(posedge clk);
		end
		apb_req (READ,'h0C,0);
		apb_req (READ,'h1C,0);		
		
		repeat (10) @(posedge clk);
		$finish;
	end

	apb_uart u_apb_uart_0 (   	
      .clk     	(clk),
	  .rstn	(rstn),
      .paddr    (paddr[3:0]),     
      .pwrite   (pwrite),
      .psel     (psel_0),
      .penable  (penable),
      .pwdata   (pwdata),
      .prdata   (prdata_0),
      .pready   (pready_0),
      .pslverr  (pslverr_0),
	  .rxd	(ser_1_to_0),
	  .txd	(ser_0_to_1)
   );

	apb_uart u_apb_uart_1 (   	
		.clk     (clk),
		.rstn  (rstn),
		.paddr    (paddr[3:0]),    
		.pwrite   (pwrite),
		.psel     (psel_1),
		.penable  (penable),
		.pwdata   (pwdata),
		.prdata   (prdata_1),
		.pready   (pready_1),
		.pslverr  (pslverr_1),
		.txd	(ser_1_to_0),
		.rxd	(ser_0_to_1)
   );

	task apb_req (
		input 		 cmd, 
		input [31:0] addr,
		input [31:0] data
	); 
		{penable,pwrite} <= 0;		
		psel_0 <= addr[31:4] == 0;
		psel_1 <= addr[31:4] == 1;
		
		case (cmd)
			WRITE: begin
				paddr  <= addr;
				pwdata <= data;
				pwrite <= 1'b1;
			end
			READ: begin
				paddr  <= addr;
				pwrite <= 1'b0;
			end    
		endcase
		@(posedge clk);
		penable <= 1;	@(posedge clk);
		{penable,psel_0,psel_1,pwrite} <= 0;	@(posedge clk);
	endtask
	
endmodule