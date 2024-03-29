//=============================================================================
// Module Name:						Async_FIFO
// Function Description:			Asynchronous FIFO
// Department:						Qualcomm (Shanghai) Co., Ltd.
// Author:							Verdvana
// Email:							verdvana@outlook.com
//-----------------------------------------------------------------------------
// Version 	Design		Coding		Simulate	Review		Rel date
// V1.0		Verdvana	Verdvana	Verdvana				2019-11-05
// V2.0		Verdvana	Verdvana	Verdvana				2021-08-07
// V2.1		Verdvana	Verdvana	Verdvana				2021-08-07
// V2.2		Verdvana	Verdvana	Verdvana				2021-10-18
// V3.0		Verdvana	Verdvana	Verdvana				2022-01-04
// V3.1		Verdvana	Verdvana	Verdvana				2022-01-12
// V3.2     Verdvana	Verdvana	Verdvana				2024-02-29
// V4.0		Verdvana	Verdvana	Verdvana				2024-03-02
//-----------------------------------------------------------------------------
// Version	Modified History
// V1.0		Asynchronous FIFO with customizable data width and fifo depth.
// V2.0		Standardize the interface and refactored code,
//			Add read&write count and almost assertion.
// V2.1		Add Write acknowledge and Valid flag.
// V2.2		Use the logarithmic system function in SystemVerilog 
//			instead of self-built function.
// V3.0		The write data width is allowed to be different from the read 
//			data width;
//			But the read data width must be 1, 1/2, 1/4, 1/8, etc. of the 
//			write data width.
//			Originally defaulted to FWFT read mode, after the update, 
//			standard read mode and FWFT read mode are optional by define.
// V3.1		Modify it to high bit first out when the read and write bit 
//			widths are inconsistent.
// V3.2     Change the selection of FWFT to parameter way instead of by define.
// V4.0		Supports read width is n times the write width, n is an interger
//			power of 2.
//=============================================================================

// Include

// Define
//`define				FPGA_EMU

//Module
module Async_FIFO #(
	parameter		WRITE_WIDTH		= 64,					// Data width
					READ_WIDTH		= 32,					// Data width
					WRITE_DEPTH		= 8,					// FIFO depth
					ALMOST_WR		= 2,					// Almost full asserted advance value
					ALMOST_RD		= 2,					// Almost empty asserted advance value
                    FWFT            = 0                     // FWFT enable, 0=STANDARD; 1=FWFT
)(
	// Clock and reset
	input									wr_clk,			// Write clock
	input									rd_clk,			// Read clock
	input									rst_n,			// Async reset					
	// Write interface
	input									wr_en,			// Write enable
	input		 [WRITE_WIDTH-1:0]			din,			// Write data
	// Read interface
	input									rd_en,			// Read enable
	output logic [READ_WIDTH-1:0]			dout,			// Read data
	// Status	
	output logic							full,			// Full flag
	output logic							empty,			// Empty flag
	output logic							almost_full,	// Almost full flag
	output logic							almost_empty,	// Almost empty flag
	output logic							wr_ack,			// Write valid
	output logic							valid,			// Read valid
	output logic [$clog2(WRITE_DEPTH-1):0]	wr_count,		// Write count
	output logic [$clog2(WRITE_DEPTH-1):0]	rd_count		// Read count
);
	//=========================================================================
	// The time unit and precision of the internal declaration
	timeunit		1ns;
	timeprecision	1ps;

	//=========================================================
	// Parameter
	localparam		TCO			= 1.6,						// Simulate the delay of the register
					DATA_DEPTH	= (READ_WIDTH>WRITE_WIDTH) ? WRITE_DEPTH/(READ_WIDTH/WRITE_WIDTH) : WRITE_DEPTH,
					ADDR_WIDTH	= $clog2(DATA_DEPTH-1),	// Address width
					DIN_WIDTH	= (READ_WIDTH>WRITE_WIDTH) ? READ_WIDTH : WRITE_WIDTH,
					MULTIPLE	= (READ_WIDTH>WRITE_WIDTH) ? 1 : 2**($clog2(WRITE_WIDTH)-$clog2(READ_WIDTH));	// The write data width is a multiple of the read data width


	//=========================================================
	//Signal
	reg 	[DIN_WIDTH-1:0]			mem [DATA_DEPTH];		// Memory bank

	logic							wren_int;
	logic	[DIN_WIDTH-1:0]			din_int;
	logic	[$clog2(READ_WIDTH/WRITE_WIDTH)-1:0]	cnt_din;

	logic	[ADDR_WIDTH-1:0]		wr_addr;				// Write address
	logic  	[ADDR_WIDTH-1:0]		rd_addr;				// Read address
	logic	[ADDR_WIDTH:0]			wr_ptr;					// Write pointer
	logic  	[ADDR_WIDTH:0]			rd_ptr;					// Read pointer
	logic	[ADDR_WIDTH:0]			wr_ptr_gray;			// Write pointer gray
	logic  	[ADDR_WIDTH:0]			rd_ptr_gray;			// Read pointer gray
	logic	[ADDR_WIDTH:0]			wr_ptr_gray_ff [2];		// Write pointer gray register
	logic  	[ADDR_WIDTH:0]			rd_ptr_gray_ff [2];		// Read pointer gray register
	logic	[ADDR_WIDTH:0]			wr_ptr_bin;				// Write pointer in reed domian
	logic  	[ADDR_WIDTH:0]			rd_ptr_bin;				// Read pointer in write domian

	logic							wr_mask;				// Write mask
	logic							rd_mask;				// Read mask


	logic	[$clog2(MULTIPLE):0]	cnt_mul;				// Multiplier Counter

	//=========================================================
	//
	generate
	if(READ_WIDTH > WRITE_WIDTH)begin
		always_ff@(posedge wr_clk, negedge rst_n)begin
			if(!rst_n)
				cnt_din	<= #TCO '0;
			else if(wr_en && (~full))
				cnt_din	<= #TCO cnt_din + 1'b1;
			else if(full)
				cnt_din	<= #TCO '0;
		end
		always_ff@(posedge wr_clk, negedge rst_n)begin
			if(!rst_n)
				wren_int	<= #TCO '0;
			else if((&cnt_din) && (~full))
				wren_int	<= #TCO 1'b1;
			else
				wren_int	<= #TCO 1'b0;
		end
		always_ff@(posedge wr_clk, negedge rst_n)begin
			if(!rst_n)
				din_int	<= #TCO '0;
			else if(wr_en && (~full))
				din_int	<= #TCO {din_int[DIN_WIDTH-1-WRITE_WIDTH:0],din};
			else if(full)
				din_int	<= #TCO '0;
		end
	end
	else begin
		assign	wren_int	= wr_en;
		assign	din_int		= din;
	end
	endgenerate
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

	assign	almost_full		= wr_count >= (DATA_DEPTH - ALMOST_WR); 
	assign	almost_empty	= rd_count <  (ALMOST_RD + 1);

	always_ff@(posedge wr_clk, negedge rst_n)begin
		if(!rst_n)begin
			wr_ack	<= #TCO '0;
		end
		else if(!wr_mask)begin
			wr_ack 	<= #TCO wren_int;
		end
		else begin
			wr_ack	<= #TCO '0;
		end
	end

	generate
		if(FWFT == 1)
			assign	valid	= ~empty;
		else
			always_ff@(posedge rd_clk)begin
				if(empty)
					valid	<= #TCO '0;
				else if(rd_en)
					valid	<= #TCO '1;
				else
					valid	<= #TCO '0;
			end
	endgenerate


	//=========================================================
	// Write side
	assign	wr_mask	= ~ (wren_int & (~full));

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
			cnt_mul	<= #TCO 1;
		end
		else if(!rd_mask)begin
			cnt_mul	<= #TCO cnt_mul + 2'b10;
		end
    end

	always_ff@(posedge rd_clk, negedge rst_n)begin
		if(!rst_n)begin
			rd_ptr	<= #TCO '0;
		end
		else if(!rd_mask && &cnt_mul)begin
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
			mem[wr_addr] <= #TCO din_int;
	end
	`else
    always_ff@(posedge wr_clk, negedge rst_n)begin
		if(!rst_n)begin
			for(int i=0;i<DATA_DEPTH;i++)begin
				mem[i]	<= #TCO '0;
			end
		end
		else if(!wr_mask) begin
			mem[wr_addr]	<= #TCO din_int;
		end
	end
	`endif

	generate
        if(FWFT == 1)
			assign  dout	= mem[rd_addr][((MULTIPLE-1-(cnt_mul>>1))*READ_WIDTH+READ_WIDTH-1)-:READ_WIDTH];
        else
			always_ff@(posedge rd_clk)begin
				if(!empty)
					dout	<= #TCO mem[rd_addr][((MULTIPLE-1-(cnt_mul>>1))*READ_WIDTH+READ_WIDTH-1)-:READ_WIDTH];
				else
					dout	<= #TCO 'z;
            end

    endgenerate
	
endmodule
