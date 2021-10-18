//=============================================================================
// Module Name:						Async_FIFO_TB
// Function Description:			Asynchronous FIFO TestBench
// Department:						Qualcomm (Shanghai) Co., Ltd.
// Author:							Verdvana
// Email:							verdvana@outlook.com
//-----------------------------------------------------------------------------
// Version 	Design		Coding		Simulata	  Review		Rel data
// V1.0		Verdvana	Verdvana	Verdvana		  			2021-08-28
// V1.1		Verdvana	Verdvana	Verdvana		  			2021-10-18
//-----------------------------------------------------------------------------
// Version	Modified History
// V1.0		Asynchronous FIFO TestBench.
// V1.1		Use the logarithmic system function in SystemVerilog 
//		instead of self-built function
//=============================================================================


//=========================================================
// The time unit and precision of the external declaration
timeunit        1ns;
timeprecision   1ps;

//=========================================================
// Include

//=========================================================
// Define

//=========================================================
// Module
module Async_FIFO_TB;

	//=========================================================
	//Parameter
    parameter		DATA_WIDTH  = 8,
					FIFO_DEPTH  = 8,
					ALMOST_WR	= 2,
					ALMOST_RD	= 1;

    parameter		TIN			= 2,
					PERIOD_0	= 333,
					PERIOD_1	= 200;

	//=========================================================
	// Signal
	logic									wr_clk;
	logic									rd_clk;
	logic									rst_n;
	logic									wr_en;
	logic	[DATA_WIDTH-1:0]				din;
	logic									rd_en;
	logic	[DATA_WIDTH-1:0]				dout;
	logic									full;
	logic									empty;
	logic									almost_full;	//Full sign
	logic									almost_empty; 	//Empty sign
	logic									wr_ack;
	logic									valid;
	logic	[$clog2(FIFO_DEPTH-1):0]		wr_count;
	logic	[$clog2(FIFO_DEPTH-1):0]		rd_count;


	//=========================================================
	// Instantiate
	`ifdef POST_SIM
	Async_FIFO_DATA_WIDTH16_ADDR_WIDTH64 u_Async_FIFO(
		.*
	);
	`else
	Async_FIFO #(
		.DATA_WIDTH(DATA_WIDTH),
		.FIFO_DEPTH(FIFO_DEPTH),
		.ALMOST_WR  (ALMOST_WR),
		.ALMOST_RD  (ALMOST_RD)
	) u_Async_FIFO(
		.*
	);
	`endif


	//=========================================================
	// Clock drive
	initial begin
		wr_clk = '0;
		forever #(PERIOD_0/2) wr_clk = ~wr_clk;
	end

	initial begin
		rd_clk = '0;
		forever #(PERIOD_1/2) rd_clk = ~rd_clk;
	end


	//=========================================================
	// Task reset
	task task_rst;
		rst_n    = '0;

		#6660;
		rst_n    = '1;
		#6660;
	endtask


	//=========================================================
	// Task init
	task task_init;
		wr_en    = '0;
		din    = '0;
		rd_en    = '0;
		#6660;
		#TIN;
	endtask

	//=========================================================
	// Task write & read
	task task_wr(logic [DATA_WIDTH-1:0]          data_in);
		wr_en   = '1;
		din = data_in;
		#PERIOD_0;
		wr_en   = '0;
	endtask
	
	task task_rd;
		rd_en   = '1;
		#PERIOD_1;
		rd_en   = '0;
	endtask
	
	//=========================================================
	// Simulation
	initial begin
	    //Reset&Init
		task_rst;
		task_init;
	
	    // Simulation behavior
		task_wr('d17);
		task_wr('d20);
		task_wr('d800);
		task_wr('d801);
		task_wr('d802);
		task_wr('d803);
		task_wr('d804);
		task_wr('d805);
		task_wr('d806);
		task_wr('d807);
		#6660;
	
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		#6660;
	
		task_wr('d1);
		task_wr('d2);
		task_wr('d3);
		task_wr('d4);
		task_wr('d5);
		task_wr('d6);
		task_wr('d7);
		task_wr('d8);
		task_wr('d9);
		task_wr('d10);
		#6660;
	
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		task_rd;
		#6660;

		$display("\033[31;5m 仿真完成! \033[0m",`__FILE__,`__LINE__);


		#400;
		$finish;
	end

	//=========================================================
	//VCS仿真
	`ifdef VCS_SIM
		//VCS系统函数
		initial begin
			$vcdpluson();                       //打开VCD+文件记录
			$fsdbDumpfile("./sim/Async_FIFO.fsdb");   //生成fsdb
			$fsdbDumpvars("+all");
			$vcdplusmemon();                    //查看多维数组
		end

		//后仿真
		`ifdef POST_SIM
		//=========================================================
		//back annotate the SDF file
		initial begin
			$sdf_annotate(	"../synthesis/mapped/Async_FIFO.sdf",
							Async_FIFO_TB.u_Async_FIFO,,,
							"TYPICAL",
							"1:1:1",
							"FROM_MTM");
			$display("\033[31;5m back annotate \033[0m",`__FILE__,`__LINE__);
		end
		`endif
	`endif

endmodule
