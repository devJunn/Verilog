module apb_uart
(
	input             	clk, rstn,      
	input				rxd,
	output				txd,
	
	input      [3:0] 	paddr,      
	input             	psel,
	input             	penable,
	input             	pwrite,
	output            	pready,
	input	   [31:0] 	pwdata,
	output reg [31:0]	prdata,   
	output            	pslverr
);

	localparam TX_IDLE = 0,
			   TX_DATA = 1,
			   RX_IDLE = 0,
			   RX_DATA = 1;

	reg [3:0] cnt, tx_cnt, rx_cnt;
	reg	tx_enable, rx_enable;
	reg [7:0] tx_data, rx_data;	
	wire	tick;
	reg tx_state, rx_state;

	reg [9:0] shift_in, shift_out;

	wire apb_write = psel & penable & pwrite;
	wire apb_read  = psel & ~pwrite;

	assign pready  = 1'b1;
	assign pslverr = 1'b0;	


	always @(posedge clk, negedge rstn)
	if	(!rstn)	tx_enable	<= 0;
	else if (apb_write && paddr == 0) tx_enable <= pwdata[0];
	else if (tx_state==TX_DATA && tx_cnt==0 && tick) tx_enable <= 0;
	
	always @(posedge clk, negedge rstn)
	if	(!rstn)	tx_data	<= 0;
	else if (apb_write && paddr == 4) tx_data <= pwdata[7:0];
	
	always @(posedge clk, negedge rstn)
	if	(!rstn)	rx_enable	<= 0;
	else if (apb_read & penable && paddr == 'hC) rx_enable <= 0;
	else if (rx_state==RX_DATA && rx_cnt== 9 && tick) rx_enable <= 1;	
	
	always @(posedge clk, negedge rstn)
	if	(!rstn)	prdata	<= 0;
	else if (apb_read)
		case (paddr)
		4'h0: prdata <= {31'b0,tx_enable};
		4'h4: prdata <= {24'b0,tx_data};
		4'h8: prdata <= {31'b0,rx_enable};
		4'hC: prdata <= {24'b0,rx_data};
		endcase
		
	assign	tick = cnt == 15;
	always @(posedge clk, negedge rstn)
	if	(!rstn)	tx_state <= TX_IDLE;
	else if (tick)
		case (tx_state)
		TX_IDLE: if (tx_enable) tx_state <= TX_DATA;
		TX_DATA: if (tx_cnt == 9) tx_state <= TX_IDLE;
		endcase
	  
	always @(posedge clk, negedge rstn)
	if	(!rstn)	shift_out <= '1;
	else if (tick)
		case (tx_state)
		TX_IDLE: shift_out <= {^tx_data,tx_data,1'b0};	//STOP
		TX_DATA: shift_out <= {1'b1,shift_out[9:1]};	//START,DATA,PARITY
		endcase
		
	assign txd = tx_state == TX_IDLE || shift_out[0];

	always @(posedge clk, negedge rstn)
	if	(!rstn)	cnt	<= 0;
	else		cnt <= cnt + 1;
	
	always @(posedge clk, negedge rstn)
	if	(!rstn)		tx_cnt <= 0;
	else if (tick)	tx_cnt <= tx_cnt==9? 0: tx_cnt+(tx_state==TX_DATA);
	
	
	always @(posedge clk, negedge rstn)
	if	(!rstn)		rx_cnt <= 0;
	else if (tick)	rx_cnt <= rx_cnt==9? 0: rx_cnt+(rx_state==RX_DATA);
	
	
	always @(posedge clk, negedge rstn)
	if	(!rstn)	rx_state <= RX_IDLE;
	else if (tick)
		case (rx_state)
		RX_IDLE: if (rxd==0) rx_state <= RX_DATA;	//START
		RX_DATA: if (rx_cnt==9) rx_state <= RX_IDLE;	//DATA,PARITY,STOP
		endcase

	always @(posedge clk, negedge rstn)
	if	(!rstn)	shift_in <= '1;
	else if (tick)
		case (rx_state)		
		RX_DATA: shift_in <= {rxd,shift_in[9:1]};
		endcase
	
	always @(posedge clk, negedge rstn)
	if	(!rstn) rx_data <= 0;
	else if (rx_state == RX_DATA && rx_cnt == 9 && tick) rx_data <= shift_in[8:1];
	
endmodule