`timescale 1ps/1ps
module SingleCycleMIPS(input clk, rst);
    wire [2:0] aluopr;
    wire [5:0] opcode,funccode;
    wire memread,memwrite,pcsrc,regdst;
    wire alusrc,memtoreg,pctoreg,lastreg;
    wire regtopc,zero, regwrite;
    MIPS_DP dp(aluopr, memread, memwrite, regwrite, pcsrc, regdst,
                alusrc, memtoreg, pctoreg, lastreg, adrtopc,
                regtopc, clk, rst, opcode, funccode, zero);
    MIPS_Controller controller(opcode, funccode, zero, adrtopc,
                                lastreg, regtopc, alusrc, regwrite, memread, memwrite,
                                memtoreg, pctoreg, regdst, pcsrc, aluopr);
endmodule

module SingleCycleMIPS_tb();
  reg clk,rst,enabled;
  SingleCycleMIPS test(clk,rst);
  initial clk = 0;
  always begin
    #50 clk = ~clk;
  end
  initial begin
    enabled = 1;
    rst = 1;
    #100 rst = 0;
  end
  always begin : loop_block
    if (enabled == 1) begin
      #100
      $display ("pc is : %b",SingleCycleMIPS_tb.test.dp.pc.out);
      $display ("opc is : %b",SingleCycleMIPS_tb.test.dp.opc);
      $display ("func is : %b",SingleCycleMIPS_tb.test.dp.func);
      $display ("Inst is : %b",SingleCycleMIPS_tb.test.dp.Inst);
      $display ("R1 is : %b",SingleCycleMIPS_tb.test.dp.register_file.R[1]);
      $display ("R2 is : %b",SingleCycleMIPS_tb.test.dp.register_file.R[2]);
      $display ("R3 is : %b",SingleCycleMIPS_tb.test.dp.register_file.R[3]);
      $display ("R4 is : %b",SingleCycleMIPS_tb.test.dp.register_file.R[4]);
      $display ("R5 is : %b",SingleCycleMIPS_tb.test.dp.register_file.R[5]);
      $display ("R6 is : %b",SingleCycleMIPS_tb.test.dp.register_file.R[6]);
      $display ("R7 is : %b",SingleCycleMIPS_tb.test.dp.register_file.R[7]);
      $display ("R8 is : %b",SingleCycleMIPS_tb.test.dp.register_file.R[8]);
      $display ("R9 is : %b",SingleCycleMIPS_tb.test.dp.register_file.R[9]);
      $display ("R10 is : %b",SingleCycleMIPS_tb.test.dp.register_file.R[10]);
      $display ("mem[2000] is : %b",SingleCycleMIPS_tb.test.dp.data_memory.Mem[2000]);
      $display ("mem[2004] is : %b",SingleCycleMIPS_tb.test.dp.data_memory.Mem[2004]);
      if (SingleCycleMIPS_tb.test.dp.opc[0] ===1'bX) begin
        enabled = 0;
        disable loop_block;
        $stop;
      end
    end else #10000;
  end
endmodule
