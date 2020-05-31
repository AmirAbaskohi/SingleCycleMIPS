module RegFile(input[4:0] ReadReg1, ReadReg2, WriteReg, input[31:0] WriteData, input clk, RegWrite, output[31:0] ReadData1, ReadData2);
  reg [31:0] R[0:31];
  initial R[0] <= 32'b0;
  always@(posedge clk) begin
    if (RegWrite == 1)begin
      if (WriteReg != 0)
        R[WriteReg] <= WriteData;
    end
  end
  assign ReadData1 = R[ReadReg1];
  assign ReadData2 = R[ReadReg2];
endmodule

module ALU(input [31:0] A,B, input[2:0] ALUOpration, output zero, output reg[31:0] Result);
  always@(A,B,ALUOpration)begin
    if(ALUOpration == 3'b000) Result =  A & B;
    else if(ALUOpration == 3'b001) Result =  A | B;
    else if(ALUOpration == 3'b010) Result =  A + B;
    else if(ALUOpration == 3'b011) Result =  A + (~B) + 1;
    else if(ALUOpration == 3'b100)begin
      if(A[31] != B[31])begin
        if(A[31] > B[31]) Result = 1;
        else Result = 0;
      end
      else begin
        if(A < B) Result = 1;
        else Result = 0;
      end
    end
  end
  assign zero = (Result == 0) ? 1'b1 : 1'b0;
endmodule

module SignExt(input [15:0] in, output [31:0]out);
  assign out = { {16{in[15]}}, in};
endmodule

module MUX_5(input[4:0] in0,in1, input sel, output[4:0] out);
  assign out = (sel == 0) ? in0 : in1;
endmodule

module MUX_32(input[31:0] in0,in1, input sel, output[31:0] out);
  assign out = (sel == 0) ? in0 : in1;
endmodule

module SHL2_32_to_32(input[31:0] in, output[31:0] out);
  assign out = {in[29:0] , 2'b00};
endmodule

module SHL2_26_to_28(input[25:0] in, output[27:0] out);
  assign out = {in,2'b00};
endmodule

module Adder_32(input [31:0] A,B, output[31:0] Result);
  assign Result = A + B;
endmodule

module InstMem(input [31:0] Address, output [5:0] OPC, output[25:0] Inst);
    reg [7:0] Mem [0:64000];
    wire [31:0] instruction;
    initial $readmemh("inst.data", Mem);
    assign instruction = {Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]};
    assign OPC = instruction[31:26];
    assign Inst = instruction[25:0];
endmodule

module DataMem(input [31:0] Address, WriteData, input MemRead, MemWrite, clk, output [31:0] ReadData);
    reg [31:0] Mem [0:16000];
    initial $readmemh("data.data", Mem);
    assign ReadData = MemRead ? Mem[Address] : 32'b0;
    always@(posedge clk)begin
        if(MemWrite == 1)begin
            Mem[Address] = WriteData;
        end
    end
endmodule

module PC_Reg(input [31:0] in, input clk, rst, output[31:0] out);
    reg [31:0] pc;
    always@(posedge clk, posedge rst)begin
        if(rst) pc <= 32'b0;
        else pc <= in;
    end
    assign out = pc;
endmodule

module Concat4_26(input [3:0] first, input [27:0] second, output[31:0] out);
  assign out = {first,second};
endmodule

module MIPS_DP(input [2:0] ALUOpration,
               input MemRead, MemWrite, RegWrite, PCSrc, RegDst, ALUSrc, MemToReg, PCToReg, LastReg, AdrToPC, RegToPC, clk, rst, 
               output [5:0] opc, func, output zero);
               
  wire [31:0] mux1_out, mux2_out, mux3_out, mux5_out, mux6_out, mux7_out;
  wire [4:0] mux4_out, mux8_out;
  wire [31:0] adder1_out, adder2_out, shl2_2_out, signext_out, concat;
  wire [27:0] shl2_1_out;
  wire [31:0] PC, RF_RD1, RF_RD2, ALU_Result, DM_RD;
  wire [25:0] Inst;
  wire [31:0] value_4;
  wire [4:0] value_31;
  
  assign value_4 = 32'b00000000000000000000000000000100;
  assign value_31 = 5'b11111;
  assign func = Inst[5:0];

  Concat4_26 concat1 (PC[31:28], shl2_1_out, concat);

  SignExt signext(Inst[15:0],signext_out);
  
  MUX_32 mux1 (mux2_out, concat, AdrToPC, mux1_out);
  MUX_32 mux2 (mux3_out, RF_RD1, RegToPC, mux2_out);
  MUX_32 mux3 (adder1_out, adder2_out, PCSrc, mux3_out);
  MUX_32 mux5 (RF_RD2, signext_out, ALUSrc, mux5_out);
  MUX_32 mux6 (ALU_Result, DM_RD, MemToReg, mux6_out);
  MUX_32 mux7 (mux6_out, adder1_out, PCToReg, mux7_out);
  
  MUX_5 mux4 (Inst[20:16], Inst[15:11], RegDst, mux4_out);
  MUX_5 mux8 (mux4_out, value_31, LastReg, mux8_out);
  
  Adder_32 adder1 (value_4, PC, adder1_out);
  Adder_32 adder2 (adder1_out, shl2_2_out, adder2_out);
  
  SHL2_26_to_28 shl2_1 (Inst, shl2_1_out);
  SHL2_32_to_32 shl2_2 (signext_out, shl2_2_out);
  
  PC_Reg pc (mux1_out, clk, rst, PC);

  InstMem instruction_memory (PC, opc, Inst);

  RegFile register_file (Inst[25:21], Inst[20:16], mux8_out, mux7_out, clk, RegWrite, RF_RD1, RF_RD2);

  ALU alu (RF_RD1, mux5_out, ALUOpration, zero, ALU_Result);

  DataMem data_memory (ALU_Result, RF_RD2, MemRead, MemWrite, clk, DM_RD);
endmodule