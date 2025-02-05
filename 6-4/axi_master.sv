module axi_master #(
	parameter AW = 32,DW=32,ID_W=4
)(

	input	clk, rstn,

	output reg               awvalid , 
   input                    awready , 
   output   [AW-1:0] awaddr  , 
   output    [3:0] awlen   , 
   output            [ 2:0] awsize  , 
   output     [ID_W-1:0] awid    , 
   output            [ 1:0] awburst , 
   // Unsupported ports (0)
   output            [ 3:0] awcache , 
   output            [ 1:0] awlock  , 
   output            [ 2:0] awprot  , 
   output            [ 3:0] awqos   , 
                           
   // write data           
   output reg               wvalid  , 
   input                    wready  , 
   output   [DW-1:0] wdata   , 
   output [DW/8-1:0] wstrb   , 
   output                   wlast   , 

   // write response    
   input                    bvalid  , 
   output                   bready  , 
   input            [ 1 :0] bresp   , 
   input      [ID_W-1:0] bid     ,
   
   //
   // Read ports
   //
   
   // Read address 
   output reg               arvalid, 
   input                    arready, 
   output   [AW-1:0] araddr , 
   output     [ID_W-1:0] arid   , 
   output    [3:0] arlen  , 
   output             [2:0] arsize , 
   output             [1:0] arburst, 
   // Unsupported ports (0)
   output             [3:0] arcache, 
   output             [1:0] arlock , 
   output             [2:0] arprot , 
   output             [3:0] arqos  , 

   // Read Data
   input                    rvalid , 
   output                   rready , 
   input    [DW-1:0] rdata  , 
   input                    rlast  , 
   input     [ID_W-1 :0] rid    ,
   input            [ 1 :0] rresp   
 );


	assign	awsize = 2;
	assign	awburst	= 1;
	assign	wstrb = 4'h1;

	assign awcache = 4'b0; 
	assign awlock  = 2'b0; 
	assign awprot  = 3'b0; 
	assign awqos   = 4'b0; 

	assign	arsize = 2;
	assign	arburst	= 1;
	assign arcache = 4'b0; 
	assign arlock  = 2'b0; 
	assign arprot  = 3'b0; 
	assign arqos   = 4'b0; 

	
	reg [3:0]	wvcnt, whcnt, awcnt, arcnt, bcnt, cnt;
	wire [3:0]	xwlen;
	wire		awfifo_full, awfifo_empty;
	
	assign bready = 1'b1;
	//assign rready = cnt[0];
	assign rready = 1;

	always @(posedge clk, negedge rstn)
	if	(!rstn)	awvalid	<= 0;
	else if (awvalid & awready) awvalid <= 0;
	else if (awcnt < 3)			awvalid <= 1;

	always @(posedge clk, negedge rstn)
	if (!rstn)	awcnt <= 0;
	else 		awcnt <= awcnt + (awvalid & awready);

	always @(posedge clk, negedge rstn)
	if (!rstn)	cnt <= 0;
	else 		cnt <= cnt + 1;


	assign	awid	= awcnt;
	assign	awsize	= 2;
	assign	awlen	= awcnt==0 ? 3: awcnt==1? 7: awcnt==2? 15: 0;
	assign	awaddr	= awcnt << 8;	//burst_length * size

	always @(posedge clk, negedge rstn)
	if	(!rstn)	begin
		wvalid	<= 0;
	end else begin
		wvalid	<= awcnt > wvcnt + (wvalid & wready & wlast);
	end

	sync_fifo #(.MODE("PREFETCH"),.DEPTH(4),.WIDTH(4)) u_awfifo(
		.clk	(clk	),	.rstn	(rstn	),
		.push	(awvalid & awready),
		.din	(awlen),
		.pop	(wvalid & wready & wlast),
		.dout	(xwlen),
		.full	(awfifo_full),
		.empty	(awfifo_empty)
	);

	assign	wdata =	{wvcnt,whcnt};
	assign	wlast = wvalid && whcnt == xwlen;
	assign	wstrb = 4'h1;

	always @(posedge clk, negedge rstn)
	if	(!rstn)		wvcnt	<= 0;
	else 			wvcnt	<= wvcnt + (wvalid & wready & wlast);
	

	always @(posedge clk, negedge rstn)
	if	(!rstn)	whcnt	<= 0;
	else if (wvalid & wready & wlast) whcnt <= 0;
	else if (wvalid & wready) whcnt <= whcnt + 1;

	always @(posedge clk, negedge rstn)
	if	(!rstn)		bcnt	<= 0;
	else 			bcnt	<= bcnt + (bvalid & bready);

	assign	bready = 1;

	always @(posedge clk, negedge rstn)
	if	(!rstn)	arvalid	<= 0;
	else if (arvalid & arready) arvalid <= 0;
	else if (arcnt < bcnt)			arvalid <= 1;

	always @(posedge clk, negedge rstn)
	if (!rstn)	arcnt <= 0;
	else 		arcnt <= arcnt + (arvalid & arready);

	assign	arid	= arcnt;
	assign	arsize	= 2;
	assign	arlen	= arcnt==0 ? 3: arcnt==1? 7: arcnt==2? 15: 0;
	assign	araddr	= arcnt << 8;	//burst_length * size

endmodule

module axi_slave #(
   parameter  ID_W=4, AW=32, DW=32  
)(  
	input                      clk,
	input                      rstn,
	//AXI write address bus ------------------------------------------
	input   [ID_W-1:0]     		awid,
	input   [AW-1:0] 		awaddr,
	input   [ 3:0]              awlen,   
	input   [ 2:0]              awsize,  
	input   [ 1:0]              awburst, 
	input   [ 1:0]              awlock,  
	input   [ 3:0]              awcache, 
	input   [ 2:0]              awprot,
	input   [ 3:0]              awqos,
	input                       awvalid, 
	output                      awready, 
	//AXI write data bus ---------------------------------------------
	input   [ID_W-1:0]      	wid,
	input   [DW-1:0]   		wdata,
	input   [DW/8-1:0]		wstrb,
	input                       wlast,   
	input                       wvalid,  
	output                      wready,  
	//AXI write response bus -----------------------------------------
	output  [ID_W-1:0]      	bid,
	output  [ 1:0]              bresp,
	output                      bvalid,
	input                       bready,
	//AXI read address bus -------------------------------------------
	input   [ID_W-1:0]      	arid,
	input   [AW-1:0] 		araddr,
	input   [ 3:0]              arlen,   
	input   [ 2:0]              arsize,  
	input   [ 1:0]              arburst, 
	input   [ 1:0]              arlock,  
	input   [ 3:0]              arcache, 
	input   [ 2:0]              arprot,
	input   [ 2:0]              arqos,
	input                       arvalid, 
	output                      arready, 
	//AXI read data bus ----------------------------------------------
	output  [ID_W-1:0]      	rid,
	output  [DW-1:0]    	rdata,
	output  [ 1:0]              rresp,
	output                      rlast, 
	output                      rvalid,
	input                       rready
);
	//burst type : INCR
	//size : 32bit
	//wstrb : all 1
	
	localparam IDLE=0,START=1,WRITE=2,READ=2,WRSP=3;

	reg [1:0]	wstate, rstate;
	reg [3:0]	wcnt, rcnt, xrcnt;

	wire	awfifo_full, awfifo_empty, arfifo_full, arfifo_empty, bfifo_full, bfifo_empty;
	wire [ID_W-1:0]	xwid, xrid;
	wire [AW-1:0] xwaddr, xraddr;

	wire [3:0]	xrlen;

	wire	we, re, we_0, we_1, we_2, re_0, re_1, re_2, sel_0, sel_1, sel_2;
	reg		re_0_d, re_1_d, re_2_d;
	wire [3:0]	wa, ra;
	wire [31:0]	wd, rd, rd_0, rd_1, rd_2;

	sync_fifo #(.MODE("KEEP"),.DEPTH(16),.WIDTH(AW+ID_W)) u_awfifo(
		.clk	(clk	),	.rstn	(rstn	),
		.push	(awvalid & awready),
		.din	({awid,awaddr}),
		.pop	(wstate == START),
		.dout	({xwid,xwaddr}),
		.full	(awfifo_full),
		.empty	(awfifo_empty)
	);

	assign	awready	= ~awfifo_full & ~bfifo_full;

	sync_fifo #(.MODE("PREFETCH"),.DEPTH(16),.WIDTH(ID_W)) u_bfifo(
		.clk	(clk	),	.rstn	(rstn	),
		.push	(wstate == WRSP),
		.din	(xwid),
		.pop	(bvalid & bready),
		.dout	(bid),
		.full	(bfifo_full),
		.empty	(bfifo_empty)
	);

	assign	bvalid	= ~bfifo_empty;
	assign	bresp	= 0;


	always @(posedge clk, negedge rstn)
	if	(!rstn)	wstate	<= IDLE;
	else begin
		case (wstate)
		IDLE:	if	(~awfifo_empty & wvalid)	
				wstate	<= START;
		START:	wstate	<= WRITE;
		WRITE:	if	(wvalid & wready & wlast)
				wstate	<= WRSP;
		WRSP:	wstate	<= IDLE;
		endcase	
	end


	reg [31:0] cnt;
	always @(posedge clk, negedge rstn)
		if (!rstn)	cnt <= 0;
		else cnt <= cnt+1;

//	assign	wready = wstate == WRITE && cnt[1:0] == 2;
	assign	wready = wstate == WRITE;

	always @(posedge clk, negedge rstn)
	if	(!rstn)	wcnt <= 0;
	else if (wvalid & wready & wlast)	wcnt <= 0;
	else if (wvalid & wready)			wcnt <= wcnt + 1;

	assign	we = wvalid & wready;
	assign	wa = xwaddr/4 + wcnt;
	assign	wd = wdata;
	
	assign	we_0	= we && xwaddr[AW-1:8] == 0;
	assign	we_1	= we && xwaddr[AW-1:8] == 1;
	assign	we_2	= we && xwaddr[AW-1:8] == 2;


	always @(posedge clk, negedge rstn)
	if	(!rstn)	rstate	<= IDLE;
	else begin
		case (rstate)
		IDLE:	if	(~arfifo_empty)	
				rstate	<= START;
		START:	rstate	<= READ;
		READ:	if	(rvalid & rready & rlast)
				rstate	<= IDLE;
		endcase	
	end

	sync_fifo #(.MODE("KEEP"),.DEPTH(16),.WIDTH(AW+ID_W+4)) u_arfifo(
		.clk	(clk	),	.rstn	(rstn	),
		.push	(arvalid & arready),
		.din	({arid,araddr,arlen}),
		.pop	(rstate == START),
		.dout	({xrid,xraddr,xrlen}),
		.full	(arfifo_full),
		.empty	(arfifo_empty)
	);

	assign	arready	= ~arfifo_full;
	assign	rvalid	= rstate == READ;
	assign	rid		= xrid;
	assign	rlast 	= rvalid && xrcnt == xrlen;
	assign	rresp	= 0;
	assign	rdata	= sel_0? rd_0: sel_1? rd_1 : sel_2? rd_2 : 0;

	assign	re		= rstate == START || (rstate == READ && rvalid & rready & ~rlast)  ;
	assign	sel_0	= xraddr[AW-1:8] == 0;
	assign	sel_1	= xraddr[AW-1:8] == 1;
	assign	sel_2	= xraddr[AW-1:8] == 2;
	assign	re_0	= re && sel_0; 
	assign	re_1	= re && sel_1; 
	assign	re_2	= re && sel_2; 



	always @(posedge clk, negedge rstn)
	if	(!rstn)	{re_0_d,re_1_d,re_2_d} <= 0;
	else		{re_0_d,re_1_d,re_2_d} <= {re_0,re_1,re_2};

	always @(posedge clk, negedge rstn)
	if	(!rstn)	rcnt <= 0;
	else if (re && rcnt == xrlen)	rcnt <= 0;
	else if (re)					rcnt <= rcnt + 1;

	always @(posedge clk, negedge rstn)
	if	(!rstn)	xrcnt <= 0;
	else if (rvalid & rready & rlast)	xrcnt <= 0;
	else if (rvalid & rready)			xrcnt <= xrcnt + 1;


	assign	ra = xraddr[5:2] + rcnt;

	tpsram #(.DEPTH(4),.WIDTH(32)) u_tpsram_0 (
		clk, we_0, wa, wd, re_0, ra, rd_0
	);
	tpsram #(.DEPTH(8),.WIDTH(32)) u_tpsram_1 (
		clk, we_1, wa, wd, re_1, ra, rd_1
	);
	tpsram #(.DEPTH(16),.WIDTH(32)) u_tpsram_2 (
		clk, we_2, wa, wd, re_2, ra, rd_2
	);

endmodule
   
module sync_fifo #(
	parameter	MODE="KEEP",
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
	
generate if (MODE=="KEEP") begin
	assign dout = mem[rd_ptr+pop-1];
end else if (MODE=="PREFETCH") begin
	assign dout = mem[rd_ptr];
end
endgenerate
		
	always @(posedge clk, negedge rstn)
	if		(!rstn)	diff_ptr <= 0;
	else			diff_ptr <= diff_ptr + push - pop;	
	
	assign	full 	= diff_ptr >= DEPTH;
	assign	a_full	= diff_ptr >= DEPTH - AF_LEVEL;
	assign	empty	= diff_ptr == 0;
	assign	a_empty = diff_ptr <= AE_LEVEL;	
	
endmodule

module tpsram #(
	parameter	DEPTH=8,
	parameter	WIDTH=32,
	parameter	DEPTH_LOG=$clog2(DEPTH)
)(
	input					clk,	//write clk
	input					we, 	//write enable
	input 	[DEPTH_LOG-1:0] wa,		//write addr
	input 		[WIDTH-1:0]	wd,		//write data
	input					re, 	//read enable
	input 	[DEPTH_LOG-1:0] ra,		//read addr
	output reg	[WIDTH-1:0]	rd		//read data
);
	reg [WIDTH-1:0]	mem[DEPTH-1:0];
	
	initial begin
		for (int i=0;i<DEPTH;i++)	mem[i] = 0;
	end
	
	always @(posedge clk)
		if (we)		mem[wa]	<= wd;
		
	always @(posedge clk)
		if (re)		rd		<= mem[ra];		
endmodule
