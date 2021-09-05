//=============================================================================
//
// Module Name:						Async_FIFO
// Function Description:			Asynchronous FIFO
// Department:						Qualcomm (Shanghai) Co., Ltd.
// Author:							Verdvana
// Email:							verdvana@outlook.com
//
//-----------------------------------------------------------------------------
//
// Version 	Design		Coding		Simulata	  Review		Rel data
// V1.0		Verdvana	Verdvana	Verdvana		  			2019-11-05
// V2.0		Verdvana	Verdvana	Verdvana		  			2021-08-07
//
//-----------------------------------------------------------------------------
//
// Version	Modified History
// V1.0		Asynchronous FIFO with customizable data width and fifo depth.
// V2.0		Standardize the interface and refactored code,
//			Add read&write count and almost assertion.
//
//=============================================================================

//The time unit and precision of the external declaration
timeunit        1ns;
timeprecision   1ps;


// Define
//`define			FPGA_EMU

//Module
module Async_FIFO #(
	parameter		DATA_WIDTH	= 8,		//Data width
					FIFO_DEPTH	= 16,		//FIFO depth
					ALMOST_WR	= 2,		//Almost full asserted advance value
					ALMOST_RD	= 2			//Almost empty asserted advance value

)(
	// Clock and reset
	input									wr_clk,			//Write clock
	input									rd_clk,			//Read clock
	input									rst_n,			//Async reset					
	// Write interface
	input									wr_en,			//Write enable
	input		 [DATA_WIDTH-1:0]			din,	    	//Write data
	// Read interface
	input									rd_en,			//Read enable
	output logic [DATA_WIDTH-1:0]			dout,	    	//Read data
	// Status	
	output logic							full,			//Full sign
	output logic							empty, 			//Empty sign
	output logic							almost_full,	//Full sign
	output logic							almost_empty, 	//Empty sign
	output logic [clogb2(FIFO_DEPTH-1):0]	wr_count,     	//Write count
	output logic [clogb2(FIFO_DEPTH-1):0]	rd_count     	//Read count
);

	//=========================================================
	// Bit width calculation function
	function integer clogb2 (input integer depth);
	begin
		for (clogb2=0; depth>0; clogb2=clogb2+1) 
			depth = depth >>1;                          
	end
	endfunction


	//=========================================================
	// Parameter
	localparam		TCO			= 1.6,
					ADDR_WIDTH	= clogb2(FIFO_DEPTH-1);

	//=========================================================
	//Signal
	reg 	[DATA_WIDTH-1:0]	mem [FIFO_DEPTH];   //Memory bank

	logic	[ADDR_WIDTH-1:0] 	wr_addr;			//Write address
	logic  	[ADDR_WIDTH-1:0] 	rd_addr;			//Read address
	logic	[ADDR_WIDTH:0] 		wr_ptr;				//Write pointer
	logic  	[ADDR_WIDTH:0] 		rd_ptr;				//Read pointer
	logic	[ADDR_WIDTH:0] 		wr_ptr_gray;		//Write pointer gray
	logic  	[ADDR_WIDTH:0] 		rd_ptr_gray;		//Read pointer gray
	logic	[ADDR_WIDTH:0] 		wr_ptr_gray_ff [2];	//Write pointer gray register
	logic  	[ADDR_WIDTH:0] 		rd_ptr_gray_ff [2];	//Read pointer gray register
	logic	[ADDR_WIDTH:0] 		wr_ptr_bin;			//Write pointer in reed domian
	logic  	[ADDR_WIDTH:0] 		rd_ptr_bin;			//Read pointer in write domian

	logic                       wr_mask;            //Write mask
	logic                       rd_mask;            //Read mask


	//=========================================================
	// Status
	assign 	full			= wr_ptr_gray == (rd_ptr_gray_ff[1] ^ {2'b11,{(ADDR_WIDTH-1){1'b0}}});
	assign 	empty			= rd_ptr_gray == wr_ptr_gray_ff[1];

	always_comb begin
		wr_ptr_bin[ADDR_WIDTH]	= wr_ptr_gray_ff[1][ADDR_WIDTH];
		rd_ptr_bin[ADDR_WIDTH]	= rd_ptr_gray_ff[1][ADDR_WIDTH];
		for(int i=(ADDR_WIDTH-1);i>=0;i--)begin:gray2bin
			wr_ptr_bin[i]	= wr_ptr_gray_ff[1][i] ^ wr_ptr_bin[i+1];
			rd_ptr_bin[i]	= rd_ptr_gray_ff[1][i] ^ rd_ptr_bin[i+1];
		end
	end

	assign	wr_count 		= wr_ptr - rd_ptr_bin;
	assign	rd_count 		= wr_ptr_bin - rd_ptr;

	assign	almost_full		= wr_count >= (FIFO_DEPTH - ALMOST_WR); 
	assign	almost_empty	= rd_count <  (ALMOST_RD + 1);

	//=========================================================
	// Write side
	assign	wr_mask	= ~ (wr_en & (~full));

	always_ff@(posedge wr_clk, negedge rst_n)begin
		if(!rst_n)begin
			wr_ptr	<= #TCO '0;
		end
		else if(!wr_mask)begin
			wr_ptr	<= #TCO wr_ptr + 1'b1;
		end
	end

	assign	wr_addr = wr_ptr[ADDR_WIDTH-1-:ADDR_WIDTH];


	//=========================================================
	// Write pointer sync
	assign	wr_ptr_gray	= (wr_ptr >> 1) ^ wr_ptr;

	always_ff@(posedge rd_clk, negedge rst_n)begin
		if(!rst_n)begin
			wr_ptr_gray_ff[0]	<= #TCO '0;
			wr_ptr_gray_ff[1]	<= #TCO '0;
		end
		else begin
			wr_ptr_gray_ff[0]	<= #TCO wr_ptr_gray;
			wr_ptr_gray_ff[1]	<= #TCO wr_ptr_gray_ff[0];
		end
	end


	//=========================================================
	// Read side
	assign  rd_mask = ~(rd_en & (~empty));

	always_ff@(posedge rd_clk, negedge rst_n)begin
		if(!rst_n)begin
			rd_ptr	<= #TCO '0;
		end
		else if(!rd_mask)begin
			rd_ptr	<= #TCO rd_ptr + 1'b1;
		end
	end

	assign	rd_addr = rd_ptr[ADDR_WIDTH-1-:ADDR_WIDTH];


	//=========================================================
	// Write pointer sync
	assign	rd_ptr_gray	= (rd_ptr >> 1) ^ rd_ptr;

	always_ff@(posedge wr_clk, negedge rst_n)begin
		if(!rst_n)begin
			rd_ptr_gray_ff[0]	<= #TCO '0;
			rd_ptr_gray_ff[1]	<= #TCO '0;
		end
		else begin
			rd_ptr_gray_ff[0]	<= #TCO rd_ptr_gray;
			rd_ptr_gray_ff[1]	<= #TCO rd_ptr_gray_ff[0];
		end
	end


	//=========================================================
	// FIFO storage
	`ifdef FPGA_EMU
	always_ff@(posedge wr_clk)begin
		if(!wr_mask)
			mem[wr_addr] <= #TCO din;
	end
	`else
    always_ff@(posedge wr_clk, negedge rst_n)begin
		if(!rst_n)begin
			for(int i=0;i<FIFO_DEPTH;i++)begin
				mem[i]	<= #TCO '0;
			end
		end
		else if(!wr_mask) begin
			mem[wr_addr]	<= #TCO din;
		end
	end
	`endif

    assign  dout	= mem[rd_addr];
	
endmodule