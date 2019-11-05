## Generated SDC file "Asy_FIFO.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Standard Edition"

## DATE    "Mon Nov 04 19:05:36 2019"

##
## DEVICE  "EP4CE10F17C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {wr_clk} -period 10.000 -waveform { 0.000 5.000 } [get_ports { wr_clk }]
create_clock -name {rd_clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports { rd_clk }]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {rd_clk}] -rise_to [get_clocks {rd_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {rd_clk}] -fall_to [get_clocks {rd_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {rd_clk}] -rise_to [get_clocks {wr_clk}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {rd_clk}] -fall_to [get_clocks {wr_clk}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {rd_clk}] -rise_to [get_clocks {rd_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {rd_clk}] -fall_to [get_clocks {rd_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {rd_clk}] -rise_to [get_clocks {wr_clk}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {rd_clk}] -fall_to [get_clocks {wr_clk}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {wr_clk}] -rise_to [get_clocks {rd_clk}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {wr_clk}] -fall_to [get_clocks {rd_clk}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {wr_clk}] -rise_to [get_clocks {wr_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {wr_clk}] -fall_to [get_clocks {wr_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {wr_clk}] -rise_to [get_clocks {rd_clk}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {wr_clk}] -fall_to [get_clocks {rd_clk}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {wr_clk}] -rise_to [get_clocks {wr_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {wr_clk}] -fall_to [get_clocks {wr_clk}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

