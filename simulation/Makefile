#===================================================================================
# Module Name:						Async_FIFO_TB
# Function Description:				Async_FIFO Simulation
# Department:						Qualcomm (Shanghai) Co., Ltd. 
# Author:							Verdvana
# Email:							verdvana@outlook.com
#------------------------------------------------------------------------------
# Version 	Design		Coding		Simulata	  Review		Rel data
# V1.0		Verdvana	Verdvana	Verdvana		  			2020-04-13
# V1.1		Verdvana	Verdvana	Verdvana		  			2021-09-05
#-----------------------------------------------------------------------------------
# Version	Modified History
# V1.0		Async_FIFO Simulation Makefile.
# V1.1		Add Verdi debug.
#===================================================================================



.PHONY: com cov sim urg clean  debugv  debugf  ccsd

#===================================================
# 定义
#=================================================== 

# 指定可执行文件名称
OUTPUT = Async_FIFO


# 宏定义
ALL_DEFINE = +define+VCS_SIM
POST_SIM_ON = +define+POST_SIM

# 指定时间单位和精度
TIME_DEF = -timescale=1ns/1ns

# 定制文件路径
#INC_DIR = 	+incdir+./rtl	\
			+incdir+./tb

# 代码覆盖率指令
CM = -cm line+cond+fsm+branch+tgl
CM_NAME = -cm_name ${OUTPUT}
CM_DIR = -cm_dir ./cm/${OUTPUT}.vdb
CM_LOG = -cm_log ./cm/cm.log
#CM_HIER = -cm_hier ./cm/cm_hier.cfg

# 后仿真库文件
#LIB_DIR = 
LIB_EXT = +libext+.v
LIB_FILE = -v ../synthesis/library/verilog/smic18.v


# 指定VPD文件名
VPD_NAME = +vpdfile+./sim/${OUTPUT}.vpd

# 编译命令
# 前仿真
VCS = vcs 	-full64 -cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,-no-as-needed \
			-sverilog	+v2k					\
			${TIME_DEF}							\
			+rad								\
			-simprofile							\
			+memcbk								\
			-debug_all							\
			+notimingcheck						\
			+nospecify							\
			+vcs+flush+all						\
			${CM}								\
			${CM_NAME}							\
			${CM_DIR}							\
			${CM_HIER}							\
			${ALL_DEFINE}						\
			${VPD_NAME}							\
			-o	./com/${OUTPUT}					\
			-l	./com/compile.log				\
			-fsdb
			
# 后仿真
# VCS = vcs 	-full64 -cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,-no-as-needed \
			-sverilog	+v2k					\
			${TIME_DEF}							\
			+rad								\
			-simprofile							\
			+memcbk								\
			-debug_all							\
			+vcs+flush+all						\
			${LIB_EXT}							\
			${LIB_FILE}							\
			${CM}								\
			${CM_NAME}							\
			${CM_DIR}							\
			${CM_HIER}							\
			${ALL_DEFINE}						\
			${POST_SIM_ON}						\
			${VPD_NAME}							\
			-o	./com/${OUTPUT}					\
			-l	./com/compile.log				\
			-fsdb

# 仿真命令
SIM = 		./com/${OUTPUT} 					\
			${CM} ${CM_NAME} ${CM_DIR} ${CM_LOG}\
			${VPD_NAME}							\
			-l ./sim/sim.log


#===================================================
# 执行
#=================================================== 

# 开始编译
com:		
			${VCS}	-f	filelist.f

# 开始仿真
sim:		
			${SIM}

# 显示覆盖率
cov:		
			dve	-full64 -covdir	./cm/*.vdb &

# 生成覆盖率报告
urg:
			urg -full64 -dir ./cm/*.vdb -format both

# Debug
debugv:		
			dve -full64	-vpd	./sim/${OUTPUT}.vpd &
debugf:
			verdi -sv -f filelist.f –ssf ./sim/*.fsdb &

# Clean
clean:      
			rm -rf	./com/*		./sim/*					\
					./profileReport	./simprofile_dir	\
					./urgReport	./DVEfiles	./csrc		\
					./cm/*.vdb	./cm/cm.log				\
					profileReport.*		*.key  			\
					novas*		./verdiLog

# 编译、仿真、Debug
ccsd:
			make clean
			make com
			make sim
			make debugv