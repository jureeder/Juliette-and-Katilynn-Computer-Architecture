/***************************************************************/
/*                                                             */
/*   RISC-V RV32 Instruction Level Simulator                   */
/*                                                             */
/*   ECEN 4243                                                 */
/*   Oklahoma State University                                 */
/*                                                             */
/***************************************************************/

#ifndef _SIM_ISA_H_
#define _SIM_ISA_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "shell.h"

//
// MACRO: Check sign bit (sb) of (v) to see if negative
//   if no, just give number
//   if yes, sign extend (e.g., 0x80_0000 -> 0xFF80_0000)
//
#define SIGNEXT(v, sb) ( v & (1 << (sb - 1)) ? ~((1 << (sb - 1)) - 1) | v : v & ((1 << (sb - 1)) - 1))

//R TYPE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

int ADD (int Rd, int Rs1, int Rs2, int Funct3) {

  if (Rd != 0 ) {
    int cur = 0;
    cur = CURRENT_STATE.REGS[Rs1] + CURRENT_STATE.REGS[Rs2];
    NEXT_STATE.REGS[Rd] = cur;
  }
  return 0;

}

int SUB (int Rd, int Rs1, int Rs2, int Funct3) {

  if (Rd != 0){
    int cur = 0;
    int rd1;
    int rd2;
    rd1 = CURRENT_STATE.REGS[Rs1];
    rd2 = CURRENT_STATE.REGS[Rs2];
    cur = rd1 - rd2;
    printf("Rd1 = %x Rd2 = %x \n", rd1, rd2);
    NEXT_STATE.REGS[Rd] = cur;
  }

  return 0;

}

int SLL (int Rd, int Rs1, int Rs2, int Funct3) {
if (Rd != 0){
  int cur = 0;
  cur = CURRENT_STATE.REGS[Rs1] << CURRENT_STATE.REGS[Rs2];
  NEXT_STATE.REGS[Rd] = cur;
}
  return 0;

}

int SLT (int Rd, int Rs1, int Rs2, int Funct3) {
if (Rd != 0){
  signed int cur = 0;
  cur = ((signed int)CURRENT_STATE.REGS[Rs1] < (signed int)CURRENT_STATE.REGS[Rs2]);
  NEXT_STATE.REGS[Rd] = cur;
}
  return 0;

}

int SLTU (int Rd, int Rs1, int Rs2, int Funct3) {
if (Rd != 0){
  unsigned int cur = 0;
  cur = ((unsigned int)CURRENT_STATE.REGS[Rs1] < (unsigned int)CURRENT_STATE.REGS[Rs2]);
  NEXT_STATE.REGS[Rd] = cur;
}
  return 0;

}

int XOR (int Rd, int Rs1, int Rs2, int Funct3) {
if (Rd != 0){
  int cur = 0;
  cur = CURRENT_STATE.REGS[Rs1] ^ CURRENT_STATE.REGS[Rs2];
  NEXT_STATE.REGS[Rd] = cur;
}
  return 0;

}

int SRL (int Rd, int Rs1, int Rs2, int Funct3) {
if (Rd != 0){
  int cur = 0;
  cur = CURRENT_STATE.REGS[Rs1] >> CURRENT_STATE.REGS[Rs2];
  NEXT_STATE.REGS[Rd] = cur;
}
  return 0;

}

int SRA (int Rd, int Rs1, int Rs2, int Funct3) {
if (Rd != 0){
  int cur = 0;
  cur = CURRENT_STATE.REGS[Rs1];
  int mask = 31;
  int shift = (mask & CURRENT_STATE.REGS[Rs2]);
  cur = cur >> shift;
  NEXT_STATE.REGS[Rd] = SIGNEXT(cur, 32 - shift);
}
  return 0;

}

int OR (int Rd, int Rs1, int Rs2, int Funct3) {
if (Rd != 0){
  int cur = 0;
  cur = CURRENT_STATE.REGS[Rs1] | CURRENT_STATE.REGS[Rs2];
  NEXT_STATE.REGS[Rd] = cur;
}
  return 0;

}

int AND (int Rd, int Rs1, int Rs2, int Funct3) {
if (Rd != 0){
  int cur = 0;
  cur = CURRENT_STATE.REGS[Rs1] & CURRENT_STATE.REGS[Rs2];
  NEXT_STATE.REGS[Rd] = cur;
}
  return 0;

}

//I TYPE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

int LB (int Rd, int Rs1, int Imm) {
  if (Rd != 0){
  int effAdr = 0;
  effAdr = CURRENT_STATE.REGS[Rs1] + SIGNEXT(Imm, 12);
  int mask = 0x3;
  int offset= effAdr & mask;
  int aligned= effAdr &~ mask;
  int read = mem_read_32(aligned);
  read = read >> (offset * 8);
  NEXT_STATE.REGS[Rd] = SIGNEXT(read, 8);
  }
  return 0;

}

int LH (int Rd, int Rs1, int Imm) {
  if (Rd != 0){
  int effAdr = 0;
  effAdr = CURRENT_STATE.REGS[Rs1] + SIGNEXT(Imm, 12);
  int mask = 0x3;
  int offset= effAdr & mask;
  int aligned= effAdr &~ mask;
  int read = mem_read_32(aligned);
  read = read >> (offset * 8);
  NEXT_STATE.REGS[Rd] = SIGNEXT(read, 16);
}
  return 0;

}

int LW (int Rd, int Rs1, int Imm) {
  
  if (Rd != 0){
    int effAdr = 0;
    effAdr = CURRENT_STATE.REGS[Rs1] + SIGNEXT(Imm, 12);
    int read = 0;
    read = mem_read_32(effAdr);
    NEXT_STATE.REGS[Rd] = read;
  }

  return 0;

}

int LBU (int Rd, int Rs1, int Imm) {
if (Rd != 0){
  int effAdr = 0;
  effAdr = CURRENT_STATE.REGS[Rs1] + SIGNEXT(Imm, 12);
  int mask = 0x3;
  int offset= effAdr & mask;
  int aligned= effAdr &~ mask;
  int read = mem_read_32(aligned);
  read = read >> (offset * 8);
  NEXT_STATE.REGS[Rd] = read & 0xFF;
}
  return 0;

}

int LHU (int Rd, int Rs1, int Imm) {
if (Rd != 0){
  int effAdr = 0;
  effAdr = CURRENT_STATE.REGS[Rs1] + SIGNEXT(Imm, 12);
  int mask = 0x3;
  int offset= effAdr & mask;
  int aligned= effAdr &~ mask;
  int read = mem_read_32(aligned);
  read = read >> (offset * 8);
  NEXT_STATE.REGS[Rd] = read & 0xFFFF;
}
  return 0;

}

int ADDI (int Rd, int Rs1, int Imm, int Funct3) {
if (Rd != 0){
  int cur = 0;
  cur = CURRENT_STATE.REGS[Rs1] + SIGNEXT(Imm,12);
  NEXT_STATE.REGS[Rd] = cur;
}
  return 0;

}

int SLLI (int Rd, int Rs1, int Imm, int Funct3) {
if (Rd != 0){
  int cur = 0;
  cur = CURRENT_STATE.REGS[Rs1] << SIGNEXT(Imm,6);  //UIMM is 5/6 bits??? 
  NEXT_STATE.REGS[Rd] = cur;
}
  return 0;

}

int SLTI (int Rd, int Rs1, int Imm, int Funct3) {
if (Rd != 0){
  signed int cur = 0;
  cur = ((signed int)CURRENT_STATE.REGS[Rs1]) < (signed int)SIGNEXT(Imm,12); 
  NEXT_STATE.REGS[Rd] = cur;
}
  return 0;

}

int SLTIU (int Rd, int Rs1, int Imm, int Funct3) {
if (Rd != 0){
  unsigned int cur = 0;
  cur = ((unsigned int)CURRENT_STATE.REGS[Rs1]) < (unsigned int)SIGNEXT(Imm,12); 
  NEXT_STATE.REGS[Rd] = cur;
}
  return 0;

}

int XORI (int Rd, int Rs1, int Imm, int Funct3) {
if (Rd != 0){
  int cur = 0;
  cur = (CURRENT_STATE.REGS[Rs1]) ^ SIGNEXT(Imm,12); 
  NEXT_STATE.REGS[Rd] = cur;
}
  return 0;

}

int SRLI (int Rd, int Rs1, int Imm, int Funct3) {
if (Rd != 0){
  int cur = 0;
  cur = CURRENT_STATE.REGS[Rs1] >> SIGNEXT(Imm,6);  
  NEXT_STATE.REGS[Rd] = cur;
}
  return 0;

}

int SRAI (int Rd, int Rs1, int Imm, int Funct3) {
if (Rd != 0){
  int cur = 0;
  cur = CURRENT_STATE.REGS[Rs1];
  int shift = (31 & SIGNEXT(Imm, 12)); 
  cur = cur >> shift; 
  NEXT_STATE.REGS[Rd] = SIGNEXT(cur, 32 - shift);
}
  return 0;

}

int ORI (int Rd, int Rs1, int Imm, int Funct3) {
if (Rd != 0){
  int cur = 0;
  cur = CURRENT_STATE.REGS[Rs1] | SIGNEXT(Imm,12);  
  NEXT_STATE.REGS[Rd] = cur;
}
  return 0;

}


int ANDI (int Rd, int Rs1, int Imm, int Funct3) {
if (Rd != 0){
  int cur = 0;
  cur = CURRENT_STATE.REGS[Rs1] & SIGNEXT(Imm,12);
  NEXT_STATE.REGS[Rd] = cur;
}
  return 0;

}

int JALR(int Rd, int Rs1, int Imm, int Funct3){

  int rd1 = CURRENT_STATE.REGS[Rs1];
  int immSignExt = SIGNEXT(Imm, 12);
  int adr = rd1 + immSignExt;
  NEXT_STATE.PC = adr - 4;
  if (Rd != 0){
  NEXT_STATE.REGS[Rd] = CURRENT_STATE.PC + 4;
  }
  return 0;

}

//B TYPE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
int BEQ (int Rs1, int Rs2, int Imm, int Funct3) {

  int cur = 0;
  Imm = Imm << 1;
  if (CURRENT_STATE.REGS[Rs1] == CURRENT_STATE.REGS[Rs2])
    NEXT_STATE.PC = (CURRENT_STATE.PC - 4) + (SIGNEXT(Imm,13));
  return 0;

}

int BNE (int Rs1, int Rs2, int Imm, int Funct3) {

  int cur = 0;
  Imm = Imm << 1;
  if (CURRENT_STATE.REGS[Rs1] != CURRENT_STATE.REGS[Rs2])
    NEXT_STATE.PC = (CURRENT_STATE.PC - 4) + (SIGNEXT(Imm,13));
  return 0;

}

int BLT (int Rs1, int Rs2, int Imm, int Funct3) {

  int cur = 0;
  Imm = Imm << 1;
  if ((signed int)CURRENT_STATE.REGS[Rs1] < (signed int)CURRENT_STATE.REGS[Rs2])
    NEXT_STATE.PC = (CURRENT_STATE.PC - 4) + (SIGNEXT(Imm,13));
  return 0;

}

int BGE (int Rs1, int Rs2, int Imm, int Funct3) {

  int cur = 0;
  Imm = Imm << 1;
  if ((signed int)CURRENT_STATE.REGS[Rs1] >= (signed int)CURRENT_STATE.REGS[Rs2])
    NEXT_STATE.PC = (CURRENT_STATE.PC - 4) + (SIGNEXT(Imm,13));
  return 0;

}

int BLTU (int Rs1, int Rs2, int Imm, int Funct3) {

  int cur = 0;
  Imm = Imm << 1;
  if ((unsigned int)CURRENT_STATE.REGS[Rs1] < (unsigned int)CURRENT_STATE.REGS[Rs2])
    NEXT_STATE.PC = (CURRENT_STATE.PC - 4) + (SIGNEXT(Imm,13));
  return 0;

}

int BGEU (int Rs1, int Rs2, int Imm, int Funct3) {

  int cur = 0;
  Imm = Imm << 1;
  if ((unsigned int)CURRENT_STATE.REGS[Rs1] >= (unsigned int)CURRENT_STATE.REGS[Rs2])
    NEXT_STATE.PC = (CURRENT_STATE.PC - 4) + (SIGNEXT(Imm,13));
  return 0;

}

//S TYPE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
int SB (int Rs1, int Rs2, int Imm) {

  int effAdr = 0;
  effAdr = CURRENT_STATE.REGS[Rs1] + SIGNEXT(Imm, 12);
  int mask = 0x3;
  int offset= effAdr & mask;
  int aligned= effAdr &~ mask;
  int read = mem_read_32(aligned);
  int rwmask = 0xFF;
  int write = CURRENT_STATE.REGS[Rs2] & rwmask;
  write = write << (offset * 8);
  rwmask = rwmask << (offset * 8);
  int mergedWriteData = read & ~rwmask; //merge read with the shifted write 
  mem_write_32(aligned, (mergedWriteData | write));

  return 0;

}

int SH (int Rs1, int Rs2, int Imm) {

  int effAdr = 0;
  effAdr = CURRENT_STATE.REGS[Rs1] + SIGNEXT(Imm, 12);
  int mask = 0x3;
  int offset= effAdr & mask;
  int aligned= effAdr &~ mask;
  int read = mem_read_32(aligned);
  int rwmask = 0xFFFF;
  int write = CURRENT_STATE.REGS[Rs2] & rwmask;
  write = write << (offset * 8);
  rwmask = rwmask << (offset * 8);
  int mergedWriteData = read & ~rwmask; //merge read with the shifted write 
  mem_write_32(aligned, (mergedWriteData | write));

  return 0;

}

int SW (int Rs1, int Rs2, int Imm) {
  
  int effAdr = 0;
  effAdr = CURRENT_STATE.REGS[Rs1] + SIGNEXT(Imm, 12);
  mem_write_32(effAdr, CURRENT_STATE.REGS[Rs2]);
  return 0;

}

//U TYPE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
int AUIPC (int Rd, int UImm) {
if (Rd != 0){
  //rd = {upimm, 12'b0} + PC
  UImm = UImm << 12;
  NEXT_STATE.REGS[Rd] = CURRENT_STATE.PC + UImm;
}
  return 0;

}

int LUI (int Rd, int UImm) {
if (Rd != 0){
  //rd = {upimm, 12'b0}
  //signed int cur = (signed int)UImm << 12;
  int cur = UImm << 12;
  NEXT_STATE.REGS[Rd] = cur;
}
  return 0;

}

//J TYPE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
int JAL (int Rd, int Imm) {

  Imm = Imm << 1;
  //PC = JTA
  NEXT_STATE.PC = CURRENT_STATE.PC - 4 + SIGNEXT(Imm,20);
  //rd = PC + 4
  if (Rd != 0){
  NEXT_STATE.REGS[Rd] = CURRENT_STATE.PC + 0x4;
  }
  return 0;

  }

/*
// I Instructions - done
int LB (char* i_);
int LH (char* i_);
int LW (char* i_);
int LBU (char* i_);
int LHU (char* i_);
int SLLI (char* i_);
int SLTI (char* i_);
int SLTIU (char* i_);
int XORI (char* i_);
int SRLI (char* i_);
int SRAI (char* i_);
int ORI (char* i_);
int ANDI (char* i_);

// U Instruction - done
int AUIPC (char* i_);
int LUI (char* i_);

// S Instruction - done
int SB (char* i_);
int SH (char* i_);
int SW (char* i_);

// R instruction - done
int SUB (char* i_);
int SLL (char* i_);
int SLT (char* i_);
int SLTU (char* i_);
int XOR (char* i_);
int SRL (char* i_);
int SRA (char* i_);
int OR (char* i_);
int AND (char* i_);

// B instructions - done
int BEQ (char* i_);
int BLT (char* i_);
int BGE (char* i_);
int BLTU (char* i_);
int BGEU (char* i_);

// I instruction
int JALR (char* i_);

// J instruction - done
int JAL (char* i_);
*/
int ECALL (char* i_){return 0;}

#endif
