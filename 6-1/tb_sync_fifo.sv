module tb_sync_fifo;
  reg clk, rstn;
  reg push, pop;
  reg [7:0] din;
  wire [7:0] dout;
  wire full,empty,a_full,a_empty;
  
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
	push <= 0;				@(posedge rstn);
    push <= 0; 			    @(posedge clk);
    push <= 1; din <= 'h10; @(posedge clk);
    push <= 1; din <= 'h11; @(posedge clk);
    push <= 1; din <= 'h12; @(posedge clk);
    push <= 1; din <= 'h13; @(posedge clk);
    push <= 0;				@(posedge clk);
  end
  
  initial begin
	pop <= 0;				@(posedge rstn);
    pop	<= 0;	repeat (8) 	@(posedge clk);
    pop	<= 1; @(posedge clk); pop <= 0;	@(posedge clk);
    pop	<= 1; @(posedge clk); pop <= 0;	@(posedge clk);
    pop	<= 1; @(posedge clk); pop <= 0;	@(posedge clk);
    pop	<= 1; @(posedge clk); pop <= 0;	@(posedge clk);
    pop <= 0;	repeat (2) 	@(posedge clk);
    $finish;
  end

    sync_fifo #(4,8,1,1) u_sync_fifo (
    clk, rstn, push, pop, din, dout, full, empty, a_full, a_empty);
  
endmodule