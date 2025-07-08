`include "code.v"
module mips_tb;
reg clk1,clk2;
integer k;

mips32 DUT(.clk1(clk1),.clk2(clk2));

initial begin
    clk1=0;
    clk2=0;
    repeat(20)
    begin
       #5 clk1=1;
       #5 clk1=0;
       #5 clk2=1;
       #5 clk2=0;
    end
end

initial
begin
      for(k=0;k<31;k++)begin
        DUT.Reg[k]=k;
      end

DUT.Mem[0]=32'h2809000a;  //to control data hazards
DUT.Mem[1]=32'h2801000a;  //ADI R1,R0,10
DUT.Mem[2]=32'h28020019;  //ADI R2,R0,25
DUT.Mem[3]=32'h28030014;  //ADI R3,R0,20
DUT.Mem[4]=32'h0ce77800;  //0R R7,R7,R7-to control data hazards
DUT.Mem[5]=32'h0ce77800;  //0R R7,R7,R7-to control data hazard
DUT.Mem[6]=32'h00432000;  //ADD R4,R3,R2
DUT.Mem[7]=32'h0ce77800;  //0R R7,R7,R7-to control data hazard
DUT.Mem[8]=32'h00832800;  //ADD R5,R4,R3
DUT.Mem[9]=32'h10623000; // SLT R6,R3,R2
DUT.Mem[10]=32'hfc000000; // HALT

    DUT.HALTED=0;
    DUT.PC=0;
    DUT.T_BRANCH=0;

#400
for(k=0;k<9;k++)
begin
     $display("R%1d-%2d",k,DUT.Reg[k]) ;
end
end

initial
begin
    $dumpfile("mips.vcd");
    $dumpvars(0,mips_tb);
    #450 $finish;
end
endmodule