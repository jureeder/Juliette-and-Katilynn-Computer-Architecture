// THIS ONE IS FOR VIVADO AND INCLUDES THE ADDITIONAL VARIABLES

// riscvsingle.sv

// RISC-V single-cycle processor
// From Section 7.6 of Digital Design & Computer Architecture
// 27 April 2020
// David_Harris@hmc.edu 
// Sarah.Harris@unlv.edu

// run 210
// Expect simulator to print "Simulation succeeded"
// when the value 25 (0x19) is written to address 100 (0x64)

//   Instruction  opcode    funct3    funct7
//   add          0110011   000       0000000
//   sub          0110011   000       0100000
//   and          0110011   111       0000000
//   or           0110011   110       0000000
//   slt          0110011   010       0000000
//   addi         0010011   000       immediate
//   andi         0010011   111       immediate
//   ori          0010011   110       immediate
//   slti         0010011   010       immediate
//   beq          1100011   000       immediate
//   lw	          0000011   010       immediate
//   sw           0100011   010       immediate
//   jal          1101111   immediate immediate


module riscvsingle (input  logic        clk, reset,
        input  logic [31:0] ReadData, Instr,
		    input  logic        PCReady,
        output logic [31:0] PC,
		    output logic      	MemWrite,
		    output logic [31:0] ALUResult, WriteData,
        output logic [3:0]  Mask,
        output logic        MStrobe);
   
   logic [1:0] 				ALUSrc;
   logic              RegWrite, Jump, Carry, Negative, V, Zero;
   logic [1:0] 				ResultSrc;
   logic [2:0]        ImmSrc;
   logic [3:0] 				ALUControl;
   logic              MemRead;
   logic              AddUIPC;
   
   controller c (Instr[6:0], Instr[14:12], Instr[30], Carry, Negative, V, Zero,
		 ResultSrc, MemWrite, AddUIPC, MStrobe, MemRead, PCSrc,
		 ALUSrc, RegWrite, Jump,
		 ImmSrc, ALUControl);
   datapath dp (clk, reset, ResultSrc, PCSrc,
		ALUSrc, RegWrite, AddUIPC,
		ImmSrc, ALUControl,
		 Negative, Zero, V, Carry, PC, Instr,
		ALUResult, WriteData, ReadData, PCReady, Mask);
   
endmodule // riscvsingle

module controller (input  logic [6:0] op,
		   input  logic [2:0] funct3,
		   input  logic       funct7b5,
		   input  logic       Carry, Negative, V, Zero,
		   output logic [1:0] ResultSrc,
		   output logic       MemWrite, AddUIPC, MemAccess, MemRead,
		   output logic       PCSrc, 
       output logic [1:0] ALUSrc,
		   output logic       RegWrite, Jump, 
		   output logic [2:0] ImmSrc,
		   output logic [3:0] ALUControl);
   
   logic [1:0] 			      ALUOp;
   logic 			            Branch;
   logic                  BranchAction;
   
   maindec md (op, ResultSrc, MemWrite, MemRead, Branch, Jump,
	        RegWrite, ALUSrc, ImmSrc, ALUOp);
   aludec ad (op[5], funct3, funct7b5, ALUOp, ALUControl);
   //                             beq bne                           blt bge                             bltu bgeu 
   //assign PCSrc = (Branch & (~funct3[2] & (Zero ^ funct3[0]) | (~funct3[1] & funct3[0] ^ (Negative ^ V)) | funct3[1] & funct3[0] ^ (~Carry)) )| Jump;
   assign PCSrc = (Branch & BranchAction) | Jump;
   assign AddUIPC = (op == 7'b0010111); // auipc
   assign MemAccess = ((op == 7'b0000011) || (op == 7'b0100011)); // load/store
   
   always_comb 
    case(funct3)
      3'b000: BranchAction = Zero; //beq
      3'b001: BranchAction = ~Zero; //bne
      3'b100: BranchAction = Negative ^ V; //blt
      3'b101: BranchAction = ~(Negative ^ V); //bge
      3'b110: BranchAction = ~Carry; //bltu
      3'b111: BranchAction = Carry; //bgeu
      default: BranchAction = 1'b0; 
    endcase

endmodule // controller

module maindec (input  logic [6:0] op,
		output logic [1:0] ResultSrc,
		output logic       MemWrite,
    output logic       MemRead,
		output logic 	     Branch, Jump,
		output logic 	     RegWrite, 
    output logic [1:0] ALUSrc,
		output logic [2:0] ImmSrc,
		output logic [1:0] ALUOp);
   
   logic [13:0] 		   controls;
   
   assign {RegWrite, ImmSrc, ALUSrc, MemWrite, MemRead,
	   ResultSrc, Branch, ALUOp, Jump} = controls;
   
   always_comb
     case(op)
       // RegWrite_ImmSrc_ALUSrc_MemWrite_MemRead_ResultSrc_Branch_ALUOp_Jump
       7'b0000011: controls = 14'b1_000_01_0_1_01_0_00_0; // I-type load 
       7'b0010011: controls = 14'b1_000_01_0_0_00_0_10_0; // I–type ALU
       7'b0010111: controls = 14'b1_100_11_0_0_00_0_11_0; // auipc
       7'b0100011: controls = 14'b0_001_01_1_0_01_0_00_0; // S-type
       7'b0110011: controls = 14'b1_xxx_00_0_0_00_0_10_0; // R–type ALU
       7'b0110111: controls = 14'b1_100_11_0_0_00_0_11_0; // lui 
       7'b1100011: controls = 14'b0_010_00_0_0_00_1_01_0; // B-type
       7'b1100111: controls = 14'b1_000_01_0_0_10_0_00_1; // jalr 
       7'b1101111: controls = 14'b1_011_11_0_0_10_0_00_1; // jal
       default: controls    = 14'bx_xxx_xx_x_x_xx_x_xx_x; // ???
     endcase // case (op)
   
endmodule // maindec

module aludec (input  logic       opb5,
	       input  logic [2:0] funct3,
	       input  logic 	    funct7b5,
	       input  logic [1:0] ALUOp,
	       output logic [3:0] ALUControl);
   
   logic 			  RtypeSub;
   
   assign RtypeSub = funct7b5 & opb5; // TRUE for R–type subtract
   assign RtypeSRA = funct7b5 & opb5; // TRUE for R–type SRA

   always_comb
     case(ALUOp)
       2'b00: ALUControl = 4'b0000; // addition, auipc
       2'b01: ALUControl = 4'b0001; // subtraction
       2'b10: case(funct3) // R–type or I–type ALU
		          3'b000: if (RtypeSub)
		            ALUControl = 4'b0001; // sub
		          else
		            ALUControl = 4'b0000; // add, addi

              3'b101: if (RtypeSRA)
		            ALUControl = 4'b1000; // srl, srli
		          else
		            ALUControl = 4'b1001; // sra, srai

              3'b001: ALUControl = 4'b0110; // sll
              3'b010: ALUControl = 4'b0101; // slt, slti
              3'b011: ALUControl = 4'b0111; // sltu
              3'b100: ALUControl = 4'b0100; // xor
		          3'b101: ALUControl = funct7b5 ? 4'b1001 : 4'b1000; // sra, srl
		          3'b110: ALUControl = 4'b0011; // or, ori
		          3'b111: ALUControl = 4'b0010; // and, andi
      
		          default: ALUControl = 4'bxxxx; // ???
		    endcase // case (funct3) 
    2'b11: ALUControl = 4'b1110; // lui
    default: ALUControl = 4'b1010;      
  endcase // case (ALUOp)
   
endmodule // aludec

module datapath (input  logic        clk, reset,
		 input  logic [1:0]  ResultSrc,
		 input  logic 	     PCSrc, 
     input  logic [1:0]  ALUSrc,
		 input  logic 	     RegWrite, AddUIPC,
		 input  logic [2:0]  ImmSrc,
		 input  logic [3:0]  ALUControl,
		 output logic 	     Negative, Zero, V, Carry, 
		 output logic [31:0] PC,
		 input  logic [31:0] Instr,
		 output logic [31:0] ALUResult, WriteData,
		 input  logic [31:0] ReadData,
     output logic        PCReady, 
     output logic [3:0]  Mask);
   
   logic [31:0] 		     PCNext, PCPlus4, PCTarget, PCTargetSrcA;
   logic [31:0] 		     ImmExt;
   logic [31:0] 		     SrcA, SrcB;
   logic [31:0] 		     Result;
   logic [31:0]          Rd1, Rd2;
   logic [7:0]           LoadByte;
   logic [15:0]          LoadHW;
   logic [7:0]           StoreByte;
   logic [15:0]          StoreHW;
   logic [31:0]          lbu, lhu, lb, lh, lw;
   logic [31:0]          sb, sh, sw;
   logic [31:0]          LoadResult;

   
   // next PC logic
   flopenr #(32) pcreg (clk, reset, PCReady, PCNext, PC);
   adder  pcadd4 (PC, 32'd4, PCPlus4);
   adder  pcaddbranch (PC, ImmExt, PCTarget);
   mux2 #(32)  pcmux (PCPlus4, PCTarget, PCSrc, PCNext);
   mux2 #(32)  pctargetmux(PC, SrcA, ALUSrc[0], PCTargetSrcA);
   // register file logic
   regfile  rf (clk, RegWrite, Instr[19:15], Instr[24:20],
	       Instr[11:7], Result, Rd1, Rd2);
   mux2 #(32) srcamux (Rd1, PC, AddUIPC, SrcA);
   extend  ext (Instr[31:7], ImmSrc, ImmExt);
   // ALU logic
   mux2 #(32)  srcbmux (Rd2, ImmExt, ALUSrc[0], SrcB); 
   alu  alu (SrcA, SrcB, PCTargetSrcA, ALUControl, ALUResult, Carry, Negative, V, Zero);
   mux3 #(32) resultmux (ALUResult, LoadResult, PCPlus4, ResultSrc, Result); 
   //mux4 #(32) resultmux (ALUResult, ReadData, PCPlus4, LoadResult, ResultSrc, Result); //Result Mux!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   // load/store instructions
   //assign Mask = ALUResult[1:0];
   //subwordwrite sww(ToWrite,Instr[13:12],ALUResult[1:0],WriteData,ByteMask); 
   //subwordread swr(ReadData,Instr[14:12],ALUResult[1:0],FromRead); 
   
   mux4 #(8) loadbytemux (ReadData[7:0], ReadData[15:8], ReadData[23:16], ReadData[31:24], ALUResult[1:0], LoadByte); 
   mux2w16 #(16) loadhwmux (ReadData[15:0], ReadData[31:16], ALUResult[1], LoadHW); 
   mux4 #(8) storebytemux (Rd2[7:0], Rd2[15:8], Rd2[23:16], Rd2[31:24], ALUResult[1:0], StoreByte);  // Is WriteData correct??????????????????????????????????????????
   mux2w16 #(16) storehwmux (Rd2[15:0], Rd2[31:16], ALUResult[1], StoreHW); 
   //mux to choose between load/store ?? opcode ????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
   
   assign lbu = {24'b0, LoadByte};
   assign lhu = {16'b0, LoadHW};
   assign lb = {{24{LoadByte[7]}}, LoadByte};
   assign lh = {{16{LoadHW[15]}}, LoadHW};
   assign lw = ReadData;
   always_comb
    case (ALUResult[1:0])
      2'b00: sb = {ReadData[31:8], StoreByte};
      2'b01: sb = {ReadData[31:16], StoreByte, ReadData[7:0]};
      2'b10: sb = {ReadData[31:24], StoreByte, ReadData[15:0]};
      2'b11: sb = {StoreByte, {24{StoreByte[7]}}};
      default: sb = 32'bx; // undefined
    endcase
  always_comb
    case (ALUResult[1])
      1'b0: sh = {ReadData[31:16], StoreHW};
      1'b1: sh = {StoreHW, ReadData[15:0]};
      default: sh = 32'bx; // undefined
    endcase
   assign sw = Rd2;
   mux5 #(32) loadresultmux (lb, lh, lw, lbu, lhu, Instr[14:12], LoadResult); // Funct3 = Instr[14:12] !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   mux3 #(32) storeresultmux (sb, sh, sw, Instr[13:12], WriteData); // Funct3 = Instr[14:12] !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   

endmodule // datapath

module adder (input  logic [31:0] a, b,
	      output logic [31:0] y);
   
   assign y = a + b;
   
endmodule

module extend (input  logic [31:7] instr,
	       input  logic [2:0]  immsrc,
	       output logic [31:0] immext);
   
   always_comb
     case(immsrc)
       // I−type
       3'b000:  immext = {{20{instr[31]}}, instr[31:20]};
       // S−type (stores)
       3'b001:  immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
       // B−type (branches)
       3'b010:  immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};       
       // J−type (jal)
       3'b011:  immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
       // U-type
       3'b100:  immext = {instr[31:12], 12'b0};
       default: immext = 32'bx; // undefined
     endcase // case (immsrc)
   
endmodule // extend

module flopr #(parameter WIDTH = 8)
   (input  logic             clk, reset,
    input logic [WIDTH-1:0]  d,
    output logic [WIDTH-1:0] q);
   
   always_ff @(posedge clk, posedge reset)
     if (reset) q <= 0;
     else  q <= d;
   
endmodule // flopr

module flopenr #(parameter WIDTH = 8)
   (input  logic             clk, reset, en,
    input logic [WIDTH-1:0]  d,
    output logic [WIDTH-1:0] q);
   
   always_ff @(posedge clk, posedge reset)
     if (reset)  q <= 0;
     else if (en) q <= d;
   
endmodule // flopenr

module mux2 #(parameter WIDTH = 8)
   (input  logic [WIDTH-1:0] d0, d1,
    input logic 	     s,
    output logic [WIDTH-1:0] y);
   
  assign y = s ? d1 : d0;
   
endmodule // mux2

module mux2w16 #(parameter WIDTH = 16)
   (input  logic [WIDTH-1:0] d0, d1,
    input logic 	     s,
    output logic [WIDTH-1:0] y);
   
  assign y = s ? d1 : d0;
   
endmodule // mux2w16

module mux3 #(parameter WIDTH = 8)
   (input  logic [WIDTH-1:0] d0, d1, d2,
    input logic [1:0] 	     s,
    output logic [WIDTH-1:0] y);
   
  assign y = s[1] ? d2 : (s[0] ? d1 : d0);
   
endmodule // mux3

module mux4 #(parameter WIDTH = 8)
   (input  logic [WIDTH-1:0] d0, d1, d2, d3,
    input logic [1:0] 	     s,
    output logic [WIDTH-1:0] y);
   
  assign y = s[1] ? (s[0] ? d3 : d2) : (s[0] ? d1 : d0); 
   
endmodule // mux4

module mux5 #(parameter WIDTH = 32)
   (input  logic [WIDTH-1:0] d0, d1, d2, d3, d4,
    input logic [2:0] 	     s,
    output logic [WIDTH-1:0] y);
   
  assign y = s[2] ? (s[0] ? d4 : d3) : (s[1] ? d2 : (s[0] ? d1 : d0)); 
   
endmodule // mux5

module imem (input  logic [31:0] a,
	     output logic [31:0] rd);
   
   logic [31:0] 		 RAM[63:0];
   
   assign rd = RAM[a[31:2]]; // word aligned
   
endmodule // imem

/*
module dmem (input  logic        clk, we,
	     input  logic [31:0] a, wd,
       input  logic [3:0] Mask,
	     output logic [31:0] rd);
   
   logic [31:0] 		 RAM[255:0], BitMask;

   assign BitMask = {{8{Mask[3]}},{8{Mask[2]}},{8{Mask[1]}},{8{Mask[0]}}};
   
   assign rd = RAM[a[31:2]]; // word aligned
   always_ff @(posedge clk)
     //if (we) RAM[a[31:2]] <= wd;
     if (we) RAM[a[31:2]] <= (rd & ~BitMask) | wd;
   
endmodule // dmem
*/

module dmem (input  logic        clk, we,
	     input  logic [31:0] a, wd,
       input  logic [3:0] Mask,
	     output logic [31:0] rd);
   
   logic [31:0] 		 RAM[255:0];
   
   assign rd = RAM[a[31:2]]; // word aligned
   always_ff @(posedge clk)
     if (we) RAM[a[31:2]] <= wd;
   
endmodule // dmem

module subwordwrite(input   logic [31:0]  ToWrite,  //added by us
                    input   logic [1:0]   Funct3_2, ByteAdr,
                    output  logic [31:0]  WriteData,
                    output  logic [3:0]   ByteMask);
    
    always_comb begin
      case(Funct3_2)
        2'b00: WriteData = {4{ToWrite[7:0]}};
        2'b01: WriteData = {2{ToWrite[15:0]}};
        2'b10: WriteData = ToWrite;
        default: WriteData = 2'bxx;
      endcase

      casex({Funct3_2,ByteAdr})
        4'b00_00: ByteMask = 4'b0001;
        4'b00_01: ByteMask = 4'b0010;
        4'b00_10: ByteMask = 4'b0100;
        4'b00_11: ByteMask = 4'b1000;
        4'b01_0x: ByteMask = 4'b0011;
        4'b01_1x: ByteMask = 4'b1100;
        4'b10_xx: ByteMask = 4'b1111;
        default:  ByteMask = 4'bxxxx;
      endcase
    end
                
endmodule

module subwordread(input  logic [31:0]  ReadData, //added by us
                   input  logic [2:0]   Funct3, 
                   input  logic [1:0]   ByteAdr,
                   output logic [31:0]  FromRead);
              
    logic [7:0]   Byte;
    logic [15:0]  Halfword;
    logic [31:0]  Word;

    always_comb begin
      case(ByteAdr)
      2'b00: Byte = ReadData[7:0];
      2'b01: Byte = ReadData[15:8];
      2'b10: Byte = ReadData[23:16];
      2'b11: Byte = ReadData[31:24];
      default: Byte = 8'hxx;
      endcase
      Halfword = (ByteAdr[1]) ? ReadData[31:16] : ReadData[15:0];
      Word = ReadData;

      case(Funct3)
      3'b000: FromRead = {{24{Byte[7]}},Byte};          //lb
      3'b100: FromRead = {{24{1'b0}},Byte};             //lbu
      3'b001: FromRead = {{16{Halfword[15]}},Halfword}; //lh
      3'b101: FromRead = {{16{1'b0}},Halfword};         //lhu
      3'b010: FromRead = Word;                          //lw
      default: FromRead = 32'hxxxxxxxx;
      endcase
    end

endmodule

module alu (input  logic [31:0] a, b, PC,
            input  logic [3:0] 	alucontrol,
            output logic [31:0] result,
            output logic        carry,
            output logic        negative,
            output logic        v,
            output logic        zero);

   logic [31:0] 	       condinvb, sum;
   logic 		       isAddSub;       // true when is add or subtract operation
   
   
   assign condinvb = alucontrol[0] ? ~b : b;
   assign sum = a + condinvb + alucontrol[0];
   //assign {carry, sum} = a + condinvb + alucontrol[0];
   //assign sum1 = PC + condinvb + alucontrol[0];
   assign isAddSub = ~alucontrol[2] & ~alucontrol[1] |
                     ~alucontrol[1] & alucontrol[0];   

   always_comb
     case (alucontrol)
       4'b0000:  result = sum;          // add, auipc
       4'b0001:  result = sum;          // subtract
       4'b0111:  result = a << b[4:0];  // sll 
       4'b0101:  result = sum[31] ^ v;  // slt   
       4'b1010:  result = ~carry;       // sltu
       4'b0110:  result = a ^ b;        // xor
       4'b1000:  result = a >> b[4:0]   ;// srl   
       4'b1001:  result = a >>> b[4:0]; // sra
       4'b0011:  result = a | b;        // or
       4'b0010:  result = a & b;        // and
       4'b1110:  result = b;            // lui
       //4'b1111:  result = sum1;         // auipc
       default: result = 32'bx;
     endcase

   assign zero = (result == 32'b0);
   assign negative = (result[31] == 1); 
   assign carry = a < b;
   assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub; //overflow
   
endmodule // alu


module regfile (input  logic        clk, 
		input  logic 	    we3, 
		input  logic [4:0]  a1, a2, a3, 
		input  logic [31:0] wd3, 
		output logic [31:0] rd1, rd2);

   logic [31:0] 		    rf[31:0];

   // three ported register file
   // read two ports combinationally (A1/RD1, A2/RD2)
   // write third port on rising edge of clock (A3/WD3/WE3)
   // register 0 hardwired to 0

   always_ff @(posedge clk)
     if (we3) rf[a3] <= wd3;	
   //assign rf[0] = 32'h00000000;
   assign rd1 = (a1 != 0) ? rf[a1] : 0;
   assign rd2 = (a2 != 0) ? rf[a2] : 0;
   
endmodule // regfile
