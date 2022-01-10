#===================================================================================
# Project Name:			    Async_FIFO
# Department:		        Qualcomm (Shanghai) Co., Ltd. 
# Function Description:	    Async_FIFO Makefile
#------------------------------------------------------------------------------
# Version 	Design		Coding		Simulate	  Review		Rel date
# V1.0	    Verdvana	Verdvana	Verdvana                    2022-01-09
#-----------------------------------------------------------------------------------
# Version	  Modified History
# V1.0		
#===================================================================================

.PHONY: com comp cov sim urg clean  debugv  debugf  ccsd

#===================================================
# 定义
#=================================================== 

# 指定可执行文件名称
OUTPUT = Async_FIFO

# 宏定义
ALL_DEFINE = +define+VCS_SIM
POST_SIM_ON = +define+POST_SIM

# 指定时间单位和精度
TIME_DEF = -timescale=1ns/1ps

# 定制文件路径
#INC_DIR = 	+incdir+./rtl	\
			+incdir+./tb

# 代码覆盖率指令
CM = -cm line+cond+fsm+branch+tgl
CM_NAME = -cm_name ${OUTPUT}
CM_DIR = -cm_dir ./../cm/${OUTPUT}.vdb
CM_LOG = -cm_log ./../cm/cm.log
#CM_HIER = -cm_hier ./../cm/cm_hier.cfg

# 后仿真库文件
#LIB_DIR = 
#LIB_EXT = +libext+.v
LIB_FILE = -v lib_file ../../synthesis/library/verilog/smic18.v


# 指定VPD文件名
VPD_NAME = +vpdfile+./../sim/${OUTPUT}.vpd

# 编译命令
# 前仿真
VCS = vcs 	-full64  -R\
			-sverilog	+v2k	+vc				\
			${TIME_DEF}							\
			+rad								\
			-debug_acc+all							\
			+notimingcheck						\
			+nospecify							\
			+vcs+flush+all						\
			${CM}								\
			${CM_NAME}							\
			${CM_DIR}							\
			${CM_LOG}							\
			${ALL_DEFINE}						\
			${VPD_NAME}							\
			-o	./../com/${OUTPUT}					\
			-l	./../com/compile.log				\
			-fsdb
			
# 后仿真
VCS_POST = vcs 	-full64 -R \
			-sverilog	+v2k  +vc					\
			${TIME_DEF}							\
			+rad								\
			-debug_all							\
			+vcs+flush+all						\
			${LIB_EXT}							\
			${LIB_FILE}							\
			${CM}								\
			${CM_NAME}							\
			${CM_DIR}							\
			${CM_LOG}							\
			${ALL_DEFINE}						\
			${POST_SIM_ON}						\
			${VPD_NAME}							\
			-o	./../com/${OUTPUT}					\
			-l	./../com/compile.log				\
			-fsdb

# 仿真命令
SIM = 		./../com/${OUTPUT} 					\
			${CM} ${CM_NAME} ${CM_DIR} ${CM_LOG}\
			${VPD_NAME}							\
			-l ./../sim/sim.log


#===================================================
# 执行
#=================================================== 

# 开始编译
com:		
			make clean
			cd ./work && ${VCS}	-f	filelist.f

comp:
			make clean
			cd ./work && ${VCS_POST} -f filelist_post.f


# 开始仿真
sim:		
			cd ./work && ${SIM}

# 显示覆盖率
cov:		
			cd ./work && dve	-full64 -covdir	./../cm/*.vdb &

# 生成覆盖率报告
urg:
			cd ./work && urg -full64 -dir ./../cm/*.vdb -format both

# Debug
debugv:		
			cd ./work && dve -full64	-vpd	./../sim/${OUTPUT}.vpd &
debugf:
			cd ./work && verdi –ssf ./../sim/*.fsdb -sv -f filelist.f &

# Clean
clean:      
			rm -rf	./com/*		./sim/*					\
					./profileReport	./simprofile_dir	\
					./work/urgReport	\
                    ./work/DVEfiles	./work/csrc		\
					./cm/*.vdb	./cm/cm.log				\
					./work/profileReport.*		./work/*.key  	\
					./work/novas*		./work/./verdiLog

# 编译、仿真、Debug
ccsd:
			make cleani
			make com
			make sim
			make debugv