//------------------------------------------------------------------------------
//
//Module Name:					Asy_FIFO.v
//Department:					Xidian University
//Function Description:	   异步FIFO
//
//------------------------------------------------------------------------------
//
//Version 	Design		Coding		Simulata	  Review		Rel data
//V1.0		Verdvana		Verdvana		Verdvana		        	2019-6-22
//
//-----------------------------------------------------------------------------------

`timescale 1ns/1ns

module Asy_FIFO #(
parameter DATA_WIDTH = 8,
parameter ADDR_WIDTH = 8
)(
/************* 时钟 *************/
	input							wr_clk,
	input							rd_clk,
/************* 使能 *************/	
	input							wr_en,
	input							rd_en,
/************* 复位 *************/	
	input							rst_n,
/************* 标志 *************/	
	output						full,
	output						empty,
/************* 数据 *************/	
	input	 [DATA_WIDTH-1:0] data_in,
	output [DATA_WIDTH-1:0] data_out

);

parameter FIFO_DEPTH = ( 1 << ADDR_WIDTH ); 	//FIFO深度定义

/************* 寄存器 *************/
reg  [ADDR_WIDTH  :0] 	wr_pointer;			//写指针
reg  [ADDR_WIDTH  :0] 	rd_pointer;			//读指针

reg  [DATA_WIDTH-1:0]	fifo [0:FIFO_DEPTH-1];	//寄存器组

wire [ADDR_WIDTH-1:0]	wr_addr;				//写地址
wire [ADDR_WIDTH-1:0]	rd_addr;				//读地址


wire [ADDR_WIDTH  :0]	wr_addr_gray;		//写地址格雷码
wire [ADDR_WIDTH  :0]	rd_addr_gray;		//读地址格雷码

reg  [ADDR_WIDTH  :0]	wr_addr_gray_d1;	//消除亚稳态一级寄存器
reg  [ADDR_WIDTH  :0]	wr_addr_gray_d2;	//消除亚稳态二级寄存器
reg  [ADDR_WIDTH  :0]	rd_addr_gray_d1;	//消除亚稳态一级寄存器
reg  [ADDR_WIDTH  :0]	rd_addr_gray_d2;	//消除亚稳态二级寄存器

//---------------------------------------------------
//读写赋值

assign wr_addr = wr_pointer[ADDR_WIDTH-1-:ADDR_WIDTH];	//写地址为写指针去掉最高位
assign rd_addr = rd_pointer[ADDR_WIDTH-1-:ADDR_WIDTH];	//读地址为读指针去掉最高位


//---------------------------------------------------
//使能同步
reg wr_en_r;
reg rd_en_r;

always@(posedge wr_clk) begin
	wr_en_r <= wr_en;
end

always@(posedge rd_clk) begin
	rd_en_r <= rd_en;
end


//---------------------------------------------------
//写

always@(posedge wr_clk) begin
	
	if(wr_en_r && (~full))
		fifo[wr_addr] <= data_in;
	
end

//---------------------------------------------------
//读

reg [DATA_WIDTH-1:0] data_out_r;

always@(posedge rd_clk) begin
	
	if(rd_en_r && (~empty))
		data_out_r <= fifo[rd_addr];
		

end

assign data_out = data_out_r;


//---------------------------------------------------
//写指针格雷码同步化
always@(posedge wr_clk) begin

	rd_addr_gray_d1 <= rd_addr_gray;		//将读地址的格雷码转移到写时钟域，方便与写地址格雷码比较
	rd_addr_gray_d2 <= rd_addr_gray_d1;	//两级触发消除亚稳态                               
 
end


always@(posedge wr_clk or negedge rst_n) begin

	if(!rst_n)
		wr_pointer <= 'h0;
		
	else if(wr_en_r && (~full))
		wr_pointer <= wr_pointer + 1;
		
	else 
		wr_pointer <= wr_pointer;
		
end


//---------------------------------------------------
//读指针格雷码同步化
always@(posedge rd_clk ) begin

	wr_addr_gray_d1 <= wr_addr_gray;		//将写地址的格雷码转移到读时钟域，方便与读地址格雷码比较
	wr_addr_gray_d2 <= wr_addr_gray_d1; //两级触发消除亚稳态                               
	
end


always@(posedge rd_clk or negedge rst_n) begin

	if(!rst_n)
		rd_pointer <= 'h0;

	else if(rd_en_r && (~empty))
		rd_pointer <= rd_pointer + 1;
		
	else 
		rd_pointer <= rd_pointer;

end

//

assign wr_addr_gray = (wr_pointer >> 1) ^ wr_pointer;	//产生写地址格雷码
assign rd_addr_gray = (rd_pointer >> 1) ^ rd_pointer;	//产生读地址格雷码

assign full = (wr_addr_gray == {~(rd_addr_gray_d2[ADDR_WIDTH-:2]),rd_addr_gray_d2[ADDR_WIDTH-2:0]});	//写地址格雷码与读地址同步后的格雷码的高两位不同 即为满
assign empty = ( rd_addr_gray == wr_addr_gray_d2 );																	//读地址格雷钠与写地址同步后的格雷码完全相同		 即为空
	

endmodule



