module apb_regs  #(		
	parameter	DW=32,
	parameter	AW=5
)(    
   input             	pclk,            
   input			 	presetn,
   
   input      [AW-1:0] 	paddr,      
   input             	psel,
   input             	penable,
   input             	pwrite,
   output            	pready,
   input	  [DW-1:0] 	pwdata,
   output reg [DW-1:0] 	prdata,   
   output            	pslverr,

   // Interface
   input      [31:0] 	status32,
   input      [15:0] 	status16,
   input      [ 7:0] 	status8,
   output reg [31:0] 	control32,
   output reg [15:0] 	control16,
   output reg [ 7:0] 	control8
);

	wire apb_write = psel & penable & pwrite;
	wire apb_read  = psel & ~pwrite;

	assign pready  = 1'b1;
	assign pslverr = 1'b0;
	
	always @(posedge pclk or negedge presetn)
	if (!presetn)	begin
		control32 <= 0;
		control16 <= 0;
		control8  <= 0;
	end else if  (apb_write)	begin
		case (paddr)
		//5'h00	:  Identification
		5'h04 : control32 <= pwdata;
		5'h08 : control16 <= pwdata[15:0];
		5'h0C : control8  <= pwdata[7:0];
		//5'h10	:  Reserved
		//5'h14 :  status32 read only 
		//5'h18 :  status16 read only 
		//5'h1C :  status8  read only 		
		endcase
	end
		
	always @(posedge pclk or negedge presetn)
	if (!presetn)	begin	
		prdata	<= 0;
	end else if (apb_read) begin
		case (paddr)
		5'h00 : prdata <= 'h12345678;
		5'h04 : prdata <= control32; 
		5'h08 : prdata <= {16'h0,control16};
		5'h0C : prdata <= {24'h0,control8};		
		//5'h10 : Reserved
		5'h14 : prdata <= status32; 
		5'h18 : prdata <= {16'h0,status16};
		5'h1C : prdata <= {24'h0,status8};
		default: prdata <= 0;
		endcase
	end 
	
endmodule