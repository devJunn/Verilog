module tb_axi;
	parameter AW = 32,DW=32,ID_W=4;
	
	reg	clk, rstn;
	// Write address
	wire			   awvalid ; 
	wire					awready ; 
	wire   [AW-1:0] awaddr  ; 
	wire	[3:0] awlen   ; 
	wire			[ 2:0] awsize  ; 
	wire	 [ID_W-1:0] awid	; 
	wire			[ 1:0] awburst ; 
	// Unsupported ports (0)
	wire			[ 3:0] awcache ; 
	wire			[ 1:0] awlock  ; 
	wire			[ 2:0] awprot  ; 
	wire			[ 3:0] awqos   ; 

	// write data		   
	wire			   wvalid  ; 
	wire					wready  ; 
	wire   [DW-1:0] wdata   ; 
	wire [DW/8-1:0] wstrb   ; 
	wire				   wlast   ; 

	// write response	
	wire					bvalid  ; 
	wire				   bready  ; 
	wire			[ 1 :0] bresp   ; 
	wire	  [ID_W-1:0] bid	 ;

	//
	// Read ports
	//

	// Read address 
	wire			   arvalid; 
	wire					arready; 
	wire   [AW-1:0] araddr ; 
	wire	 [ID_W-1:0] arid   ; 
	wire	[3:0] arlen  ; 
	wire			 [2:0] arsize ; 
	wire			 [1:0] arburst; 
	// Unsupported ports (0)
	wire			 [3:0] arcache; 
	wire			 [1:0] arlock ; 
	wire			 [2:0] arprot ; 
	wire			 [3:0] arqos  ; 

	// Read Data
	wire					rvalid ; 
	wire				   rready ; 
	wire	[DW-1:0] rdata  ; 
	wire					rlast  ; 
	wire	 [ID_W-1 :0] rid	;
	wire			[ 1 :0] rresp ;  

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
		wait (rid == 2);
		wait (rlast);
		repeat (5) @(posedge clk);
		$finish;
	end

	initial begin
		repeat (200) @(posedge clk);
		$finish;
	end

	axi_master #(.ID_W(ID_W),.AW(AW),.DW(DW)) u_axi_master(
		.clk	(clk),
		.rstn	(rstn),
		.awvalid 		(awvalid ),  
		.awready        (awready ), 
		.awaddr         (awaddr  ), 
		.awlen          (awlen   ), 
		.awsize         (awsize  ), 
		.awid	       (awid	), 
		.awburst        (awburst ), 
		.awcache        (awcache ), 
		.awlock         (awlock  ), 
		.awprot         (awprot  ), 
		.awqos          (awqos   ), 
		.wvalid         (wvalid  ), 
		.wready         (wready  ), 
		.wdata          (wdata   ), 
		.wstrb          (wstrb   ), 
		.wlast          (wlast   ), 
		.bvalid         (bvalid  ), 
		.bready         (bready  ), 
		.bresp          (bresp   ), 
		.bid	           (bid	 ),
		.arvalid        (arvalid), 
		.arready        (arready), 
		.araddr         (araddr ), 
		.arid           (arid   ), 
		.arlen          (arlen  ), 
		.arsize         (arsize ), 
		.arburst        (arburst), 
		.arcache        (arcache), 
		.arlock         (arlock ), 
		.arprot         (arprot ), 
		.arqos          (arqos  ), 
		.rvalid         (rvalid ), 
		.rready         (rready ), 
		.rdata          (rdata  ), 
		.rlast          (rlast  ), 
		.rid	           (rid	),
		.rresp           (rresp ) 
	);

	axi_slave #(.ID_W(ID_W),.AW(AW),.DW(DW)) u_axi_slave(
		.clk	(clk),
		.rstn	(rstn),
		.awvalid 		(awvalid ),  
		.awready        (awready ), 
		.awaddr         (awaddr  ), 
		.awlen          (awlen   ), 
		.awsize         (awsize  ), 
		.awid	       (awid	), 
		.awburst        (awburst ), 
		.awcache        (awcache ), 
		.awlock         (awlock  ), 
		.awprot         (awprot  ), 
		.awqos          (awqos   ), 
		.wvalid         (wvalid  ), 
		.wready         (wready  ), 
		.wdata          (wdata   ), 
		.wstrb          (wstrb   ), 
		.wlast          (wlast   ), 
		.wid	           (wid	 ), 
		.bvalid         (bvalid  ), 
		.bready         (bready  ), 
		.bresp          (bresp   ), 
		.bid	           (bid	 ),
		.arvalid        (arvalid), 
		.arready        (arready), 
		.araddr         (araddr ), 
		.arid           (arid   ), 
		.arlen          (arlen  ), 
		.arsize         (arsize ), 
		.arburst        (arburst), 
		.arcache        (arcache), 
		.arlock         (arlock ), 
		.arprot         (arprot ), 
		.arqos          (arqos  ), 
		.rvalid         (rvalid ), 
		.rready         (rready ), 
		.rdata          (rdata  ), 
		.rlast          (rlast  ), 
		.rid	           (rid	),
		.rresp           (rresp ) 
	);
endmodule