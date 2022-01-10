//=============================================================================
//
// Module Name:						Async_FIFO_TB
// Function Description:			Asynchronous FIFO TestBench
// Department:						Qualcomm (Shanghai) Co., Ltd.
// Author:							Verdvana
// Email:							verdvana@outlook.com
//
//-----------------------------------------------------------------------------
//
// Version 	Design		Coding		Simulata	  Review		Rel data
// V1.0		Verdvana	Verdvana	Verdvana		  			2021-08-28
//
//-----------------------------------------------------------------------------
//
// Version	Modified History
// V1.0		Asynchronous FIFO TestBench
//
//=============================================================================

//=========================================================
// The time unit and precision of the external declaration
//timeunit        1ns;
//timeprecision   1ps;

//=========================================================
// Include

//=========================================================
// Define

//=========================================================
// Module
module Async_FIFO_TB;

    //=========================================================
    //Parameter
    parameter		WRITE_WIDTH = 8,
                    READ_WIDTH  = 4,
					WRITE_DEPTH = 8,
					ALMOST_WR	= 2,
					ALMOST_RD	= 1;

    parameter       TIN     = 2,
                    PERIOD_0   = 150,
                    PERIOD_1   = 200;

    //=========================================================
    // Signal
    logic 									wr_clk;
    logic 									rd_clk;
    logic 									rst_n;
    logic 									wr_en;
    logic 		 [WRITE_WIDTH-1:0]			din;
    logic 									rd_en;
    logic   [READ_WIDTH-1:0]				dout;
    logic  									full;
    logic  									empty;
	logic									almost_full;	//Full sign
	logic									almost_empty; 	//Empty sign
    logic                                   wr_ack;
    logic                                   valid;
    logic   [$clog2(WRITE_DEPTH-1):0]		wr_count;
    logic   [$clog2(WRITE_DEPTH-1):0]		rd_count;




    //=========================================================
    // Instantiate
    Async_FIFO #(
        .WRITE_WIDTH(WRITE_WIDTH),
        .READ_WIDTH(READ_WIDTH),
        .WRITE_DEPTH(WRITE_DEPTH),
        .ALMOST_WR  (ALMOST_WR),
        .ALMOST_RD  (ALMOST_RD)
    ) u_Async_FIFO(
        .*
    );


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

        #60;
        rst_n    = '1;
        #60;
    endtask


    //=========================================================
    // Task init
    task task_init;
        wr_en    = '0;
        din    = '0;
        rd_en    = '0;
        #60;
        #TIN;
    endtask

    //=========================================================
    // Task write & read
    task task_wr(logic [WRITE_WIDTH-1:0]          data_in);
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

    task task_wr_continuous(int x);
        for(int i=0;i<x;i++)
            task_wr(i);
    endtask

    task task_rd_continuous(int x);
        for(int i=0;i<x;i++)
            task_rd;
    endtask


    //=========================================================
    // Simulation
    initial begin
        //Reset&Init
        task_rst;
        task_init;

        // Simulation behavior
        task_wr(8'b0101_1111);
        task_wr(8'b0000_0110);
        task_wr(8'b0101_1010);
        task_wr(8'd1111_0000);
        //task_wr('d802);
        //task_wr('d803);
        //task_wr('d804);
        //task_wr('d805);
        //task_wr('d806);
        //task_wr('d807);
        #660;

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
        #660;

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
        #660;

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
        task_rd;
        task_rd;
        #660;

        fork
            task_wr_continuous(16);
            task_rd_continuous(32);
        join

        #660;

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
            $fsdbDumpfile("./../../simulation/sim/Async_FIFO.fsdb");   //生成fsdb
            $fsdbDumpvars("+all");
            $vcdplusmemon();                    //查看多维数组
        end

        //后仿真
        `ifdef POST_SIM
        //=========================================================
        //back annotate the SDF file
        initial begin
            $sdf_annotate(	"./../../synthesis/mapped/Async_FIFO.sdf",
                            Async_FIFO_TB.u_Async_FIFO,,,
                            "TYPICAL",
                            "1:1:1",
                            "FROM_MTM");
            $display("\033[31;5m back annotate \033[0m",`__FILE__,`__LINE__);
        end
        `endif
    `endif

    
endmodule
