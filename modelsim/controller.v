module SignalController(input [5:0] opcode, output reg adrtopc, lastreg, regtopc,
                        alusrc, regwrite, beq, bne, memread, memwrite,
                        memtoreg, pctoreg, regdst, output reg [1:0] aluop);
    always@(opcode)begin
      if(opcode == 6'b000000)begin // r_type
        {adrtopc,lastreg,regtopc,alusrc,regwrite,beq,bne,memread,memwrite,memtoreg,pctoreg,regdst} = 12'b000010000001;
        aluop = 2'b10;
      end
      else if(opcode == 6'b001100 || opcode == 6'b001000)begin //addi andi
        {adrtopc,lastreg,regtopc,alusrc,regwrite,beq,bne,memread,memwrite,memtoreg,pctoreg,regdst} = 12'b000110000000;
        aluop = (opcode == 6'b001100) ? 2'b11 : 2'b00;
      end
      else if(opcode == 6'b100011)begin //lw
        {adrtopc,lastreg,regtopc,alusrc,regwrite,beq,bne,memread,memwrite,memtoreg,pctoreg,regdst} = 12'b000110010100;
        aluop = 2'b00;
      end
      else if(opcode == 6'b101011)begin //sw
        {adrtopc,lastreg,regtopc,alusrc,regwrite,beq,bne,memread,memwrite,memtoreg,pctoreg,regdst} = 12'b000100001000;
        aluop = 2'b00;
      end
      else if(opcode == 6'b000100)begin //beq
        {adrtopc,lastreg,regtopc,alusrc,regwrite,beq,bne,memread,memwrite,memtoreg,pctoreg,regdst} = 12'b000001000000;
        aluop = 2'b01;
      end
      else if(opcode == 6'b000101)begin //bne
        {adrtopc,lastreg,regtopc,alusrc,regwrite,beq,bne,memread,memwrite,memtoreg,pctoreg,regdst} = 12'b000000100000;
        aluop = 2'b01;
      end
      else if(opcode == 6'b000010)begin //j
        {adrtopc,lastreg,regtopc,alusrc,regwrite,beq,bne,memread,memwrite,memtoreg,pctoreg,regdst} = 12'b100000000000;
        aluop = 2'b00;
      end
      else if(opcode == 6'b100000)begin //jr
        {adrtopc,lastreg,regtopc,alusrc,regwrite,beq,bne,memread,memwrite,memtoreg,pctoreg,regdst} = 12'b001000000000;
        aluop = 2'b00;
      end
      else if(opcode == 6'b000011)begin//jal
        {adrtopc,lastreg,regtopc,alusrc,regwrite,beq,bne,memread,memwrite,memtoreg,pctoreg,regdst} = 12'b110010000010;
        aluop = 2'b00;
      end
    end
endmodule

module ALUControllerC(input [1:0] aluop, input [5:0] funccode, output reg [2:0] aluoperation);
    always@(aluop, funccode)begin
      if(aluop == 2'b10)begin
        if(funccode == 6'b100000) aluoperation = 3'b010;
        else if(funccode == 6'b100100) aluoperation = 3'b000;
        else if(funccode == 6'b100101) aluoperation = 3'b001;
        else if(funccode == 6'b100010) aluoperation = 3'b011;
        else if(funccode == 6'b101010) aluoperation = 3'b100;
      end
      else if(aluop == 2'b00) aluoperation = 3'b010;
      else if(aluop == 2'b01) aluoperation = 3'b011;
      else if(aluop == 2'b11) aluoperation = 3'b000;
    end
endmodule

module MIPS_Controller(input [5:0] opcode, funccode, input zero, output adrtopc,
                        lastreg, regtopc, alusrc, regwrite, memread, memwrite,
                        memtoreg, pctoreg, regdst, pcsrc, output [2:0] aluopr);
    wire be,bn;
    wire [1:0] op;
    SignalController sc(opcode, adrtopc, lastreg, regtopc, alusrc, regwrite, be, bn, memread, memwrite, memtoreg, pctoreg, regdst, op);
    ALUControllerC aluc(op, funccode, aluopr);
    assign pcsrc = (zero & be) | ((~zero) & bn);
endmodule