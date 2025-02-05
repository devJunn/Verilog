module tb_apb_regs;
	localparam AW=5, DW=32;
	localparam WRITE=1, READ=0;
	
	reg   			pclk, presetn;
	
	reg   [31:0] 	paddr;
	reg          	penable, pwrite;
	reg	  [DW-1:0] 	pwdata;	
	reg				psel_0;
	wire            pready_0, pslverr_0;	
	wire  [DW-1:0] 	prdata_0;
	reg				psel_1;
	wire            pready_1, pslverr_1;	
	wire  [DW-1:0] 	prdata_1;
	
	// Interface
	reg  [31:0] 	status32_0,		status32_1;
	reg  [15:0] 	status16_0,     status16_1;
	reg  [ 7:0] 	status8_0,      status8_1;
	wire [31:0] 	control32_0,    control32_1;
	wire [15:0] 	control16_0,    control16_1;
	wire [ 7:0] 	control8_0,     control8_1;
	
	initial begin
		pclk	= 0;
		forever #5 pclk = ~pclk;
	end

	initial begin
		presetn = 1;
		#20 presetn = 0;
		#30 presetn = 1;
	end

	initial begin
		{penable,psel_0,psel_1,pwrite} <= 0;
		@(posedge presetn);
		repeat (2) @(posedge pclk);
		for (int i=0;i<'h20;i=i+4) apb_req (WRITE, 'h00 + i, 'hFFFFFF00+i);
		for (int i=0;i<'h20;i=i+4) apb_req (WRITE, 'h20 + i, 'hFFFFFF80+i);
		for (int i=0;i<'h20;i=i+4) apb_req (READ , 'h00 + i, 0);	
		for (int i=0;i<'h20;i=i+4) apb_req (READ , 'h20 + i, 0);	
		repeat (2) @(posedge pclk);
		$finish;
	end

	assign status32_0	= 'h32032032;
	assign status16_0	= 'h1601;
	assign status8_0	= 'h80;

	assign status32_1	= 'h32132132;
	assign status16_1	= 'h1611;
	assign status8_1	= 'h81;


	task apb_req (
		input 		 cmd, 
		input [31:0] addr,
		input [31:0] data
	); 
		{penable,pwrite} <= 0;		
		psel_0 <= addr[31:AW] == 0;
		psel_1 <= addr[31:AW] == 1;
		
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
		@(posedge pclk);
		penable <= 1;	@(posedge pclk);
		{penable,psel_0,psel_1,pwrite} <= 0;	@(posedge pclk);
	endtask


	apb_regs #(.DW(DW), .AW(AW)) u_apb_regs_0 (   	
      .pclk     (pclk),
	  .presetn	(presetn),
      .paddr    (paddr[AW-1:0]),     
      .pwrite   (pwrite),
      .psel     (psel_0),
      .penable  (penable),
      .pwdata   (pwdata),
      .prdata   (prdata_0),
      .pready   (pready_0),
      .pslverr  (pslverr_0),

	  // Interface
      .status32 (status32_0),
      .status16 (status16_0),
      .status8  (status8_0 ),
      .control32(control32_0),
      .control16(control16_0),
      .control8 (control8_0) 
   );

	apb_regs #(.DW(DW), .AW(AW)) u_apb_regs_1 (   	
		.pclk     (pclk),
		.presetn  (presetn),
		.paddr    (paddr[AW-1:0]),    
		.pwrite   (pwrite),
		.psel     (psel_1),
		.penable  (penable),
		.pwdata   (pwdata),
		.prdata   (prdata_1),
		.pready   (pready_1),
		.pslverr  (pslverr_1),
		
		// Interface
		.status32 (status32_1),
		.status16 (status16_1),
		.status8  (status8_1 ),
		.control32(control32_1),
		.control16(control16_1),
		.control8 (control8_1) 
   );
endmodule