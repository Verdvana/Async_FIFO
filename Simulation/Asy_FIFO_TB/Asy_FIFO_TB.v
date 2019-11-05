`timescale 1ns/1ns

module Asy_FIFO_TB;

parameter DATA_WIDTH = 3;
parameter ADDR_WIDTH = 3;

parameter FIFO_DEPTH = ( 1 << ADDR_WIDTH );

reg wr_clk;
reg rd_clk;

reg rst_n;

reg wr_en;
reg rd_en;

reg [DATA_WIDTH-1:0] data_in;

wire full;
wire empty;

wire [DATA_WIDTH-1:0] data_out;


Asy_FIFO #(
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH)
)
u_Syn_FIFO(

	.wr_clk(wr_clk),
	.rd_clk(rd_clk),
	.rst_n(rst_n),
	
	.wr_en(wr_en),
	.rd_en(rd_en),
	
	.data_in(data_in),
	
	.full(full),
	.empty(empty),
	
	.data_out(data_out)
	
);

initial begin
	wr_clk = 0;
	forever #10 wr_clk=~wr_clk;
end

initial begin
	rd_clk = 0;
	forever #5 rd_clk=~rd_clk;
end


task task_rst;
begin
	rst_n = 0;
	repeat(2)@(negedge wr_clk);
	rst_n = 1;
end
endtask

task task_sysinit;
begin
	wr_en = 0;
	rd_en = 0;
	data_in = 0;
end
endtask


initial
begin
	task_sysinit;
	task_rst;
	#10;
	
	wr_en = 1;
	
	
	repeat(FIFO_DEPTH)@(posedge wr_clk) begin
		data_in = data_in + 1;
	end
	
	#60;
	
	wr_en = 0;
	
	#60;
	
	rd_en = 1;
	
	#100;
	
	rd_en = 0;
	
	#40;
	
	wr_en = 1;
	
	
	repeat(FIFO_DEPTH)@(posedge wr_clk) begin
		data_in = data_in + 1;
	end
	
	#60;
	
	wr_en = 0;
	
	#60;
	
	rd_en = 1;
	
	#200;
	
	rd_en = 0;
	
	#40;
	
	
		
		
	

	
end

endmodule
