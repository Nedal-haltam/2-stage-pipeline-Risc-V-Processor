# 2-stage-pipeline-Risc-V-Processor
In this repository, I introduced an implementation of a 2-stage pipelined Risc-V Processor using Verilog and built an Assembler along with it to make it easier to write programs so you can write them on the instruction memory and execute it.

features:<br />
1- Avoids any hazards by utilizing the edges of the clock when fetching an instruction and executing it.<br />
2- no bubble (nop) in this implementation so there is no any sort of delay instroduced in the pipelining.<br />
3- there is a hlt instruction to halt the cpu automatically when ever it is fetched.<br />
    
To write Instructions on the instruction memory you first use the assembler program to write the code on the left textbox and then you copy the output of the assembler from the right text box. but here you should copy
the Verilog code that is written not the machine code see the below example for further understanding.


![image](https://github.com/Nedal-haltam/2-stage-pipeline-Risc-V-Processor/assets/133881380/cbf6c35c-9d8b-405e-a147-e7685baa7ec5)

As you can see the highlighted text this is what you should paste into the CPU module in Verilog and then let it run for enough clock cycles and see the output in the console for observing the register file and memory
contents 

note: the first edge that enters the CPU is a negative edge so that the registers between the fetch and the execution stage latch the instruction from the instruction memory addressed by the initialized
register PC1 (see block diagram). And then it increaments normally and automatically.
