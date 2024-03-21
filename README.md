# MIPS_CPU
A MIPS CPU based on Xilinx EGO1 board 
- Dmem32.v 内存RAM的管理模块
- Ifetc32.v 取指令模块
- MemOrIO.v IO和Memory数据的控制模块
- Vga.v VGA模块，显示一些CPU的內部数据
- control32.v 总控制器，主要负责取指和寄存器之间的数据传递控制
- cpu.xdc Xilinx EGO1板的端口配置
- decode32.v Decoder模块
- dmem32.coe 内存的初始化文件
- executs32.v 计算器模块
- ioread.v IO读取模块
- leds.v LED灯模块
- prgmip32.coe test_final.asm文件转化为机器码后，在内存中的配置文件
- test_final.asm 用于测试的汇编代码
- top.bit 项目生成的比特流文件，开发板直接可用
- top.v 顶层模块，组合所有模块
