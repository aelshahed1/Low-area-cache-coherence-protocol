# Low-area-cache-coherence-protocol

This repository contains the design files for my MSC dissertation at the University of Southampton. The dissertation is titled "Optimising Area Cost for a Multi-Core Cache Coherence Protocol". The project was supervised by Professor David Thomas. The project is described in the following abstract:

“Multi-core designs are the recent trend in high-performance systems. Systems with multiple processors and multi-levels of caches are present in most modern digital systems. In these systems, maintaining coherence between cache memories is a critical factor in the system’s execution. As a result, the growing amount of hardware resource needed to ensure cache coherency presents a serious threat to the overall performance of multi-core systems. In this project, a new snoopy coherence protocol was designed to optimise the resources utilisation of existing protocols. The developed protocol was tested in a dual-core system which was designed from scratch using SystemVerilog RTL. The MESI coherence protocol was used as a reference to compare several system attributes. The proposed coherence protocol saves around 3% in combinational elements and around 11% in sequential elements on the targeted FPGA chip. The maximum achievable frequency of the designed system is 41 MHz.”

The proposed system is a dual-core system with two levels of cache memory. The designed processors are identical copies of a 32-bit, 2-stage pipelined RV32I that can perform multiplication. Each processor owns a level 1 cache and they both share the same level 2 cache. The shared level 2 cache memory communicates with the bigger main memory for data requests. The system presented in the figure below is aimed to be the platform of comparison between different cache coherence protocols.

![alt text](https://github.com/aelshahed1/Low-area-cache-coherence-protocol/blob/main/System%20Diagram.png)

After verifying the RTL design, the system was implemented on an FPGA development board. In RTL simulation, several methods could be used to obtain data from the designed system. On the other hand, a data interface must be developed for FPGA implementations. The FPGA development board used in this project is the Digilent Arty Z7 board which is designed around the Zynq-7000 SoC. This board accommodates very few I/O peripherals due to its small size. However, the Zynq-7000 SoC contains 2 ARM Cortex-A9 processors which could be highly valuable for various applications. In this project, an ARM processor was used to receive cache data from the designed system and display the results via a UART peripheral. To realise this functionality, the verified RTL was integrated with a number of Xilinx IP blocks from the Vivado IP Library. The figure below shows the block diagram of the implemented SoC design.  

![alt text](https://github.com/aelshahed1/Low-area-cache-coherence-protocol/blob/main/SoC%20Design%20Block%20Diagram.png)

For more details, please check the full dissertation at https://drive.google.com/file/d/1loNT2WEk0zUx4h-dntssPuKt_Umy0QWc/view?usp=share_link
