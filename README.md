# 2-stage-pipeline-Risc-V-Processor
In this repository I introduced an implementation of a 2 stage pipelined Risc-V Processor using Verilog and build an Assembler along with it to make it easier to write programs so you can write it on the instruction memory and execute it

features:
1- Avoids any hazards by utilizing the edges of the clock when fetching an instruction.
2- no bubble (nop) in this implementation so there is any sort of delay instroduced due to pipelining.
3- there is a hlt instruction to halt the cpu automatically when ever it fetch it.
    
To write Instruction on the instruction memory you first use the assembler program to write the code on the left textbox and the you copy the output of the assembler from the right text box. but here you should copy
the verilog code that is written not the machine code see the below example for further understanding.


![image](https://github.com/Nedal-haltam/2-stage-pipeline-Risc-V-Processor/assets/133881380/cbf6c35c-9d8b-405e-a147-e7685baa7ec5)

see the highlighted text this what you will paste in the cpu module in verilog and then let it run for enough time and see the output in console for observing the register file and data memory contents 

note: the first edge that enters the cpu is a negative edge so that the registers between the fetch and the execution stage latch the instruction from the instruction memory addressed by the initialized
register PC1 (see block diagram). And then it increaments normally and automatically.
