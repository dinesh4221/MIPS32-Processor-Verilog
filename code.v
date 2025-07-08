module mips32(clk1,clk2);
input clk1,clk2;                                          //two phase clock(control data hazards)
reg [31:0] PC,IF_ID_NPC,IF_ID_IR;                         //if_id latch
reg [31:0] ID_EX_IR,ID_EX_NPC,ID_EX_A,ID_EX_B,ID_EX_IMM;  //id_ex latch
reg [31:0] EX_MEM_IR,EX_MEM_ALUOUT,EX_MEM_B;              //ex_mem latch
reg EX_MEM_COND;                                          //checks if a==0
reg HALTED;                                               //is set after instruction is completed
reg T_BRANCH;                                             //set to disable instructions after branch
reg [31:0] MEM_WB_IR,MEM_WB_ALUOUT,MEM_WB_LMD;            //mem_wb latch
reg[2:0] ID_EX_TYPE,EX_MEM_TYPE,MEM_WB_TYPE;

reg [31:0] Reg [31:0];                                    //32*32 register bank
reg [31:0] Mem [1023:0];                                  //1024*32 memory

parameter ADD = 6'b000000, SUB = 6'b000001,AND = 6'b000010, OR = 6'b000011,SLT = 6'b000100, MUL= 6'b000101, 
           HLT = 6'b111111,LW= 6'b001000, SW= 6'b001001, ADI = 6'b001010,
          SBI = 6'b001011, SLTI = 6'b001100, BNEQZ = 6'b001101, BEQZ = 6'b001110;          //opcode

parameter RR_ALU=3'b000,RM_ALU=3'b001,LOAD=3'b010,STORE=3'b011,BRANCH=3'b100,HALT=3'b101;

//IF STAGE
always@(posedge clk1)begin
if(HALTED==0)
begin
    if(((EX_MEM_IR[31:26]==BEQZ)&&(EX_MEM_COND==1))||((EX_MEM_IR[31:26]==BNEQZ)&&(EX_MEM_COND==0)))
    begin
        IF_ID_IR <= #2 Mem[EX_MEM_ALUOUT];
        T_BRANCH <= #2 1'b1;
        IF_ID_NPC <= #2 EX_MEM_ALUOUT+1;
        PC <= #2 EX_MEM_ALUOUT+1;             //PC==NPC
    end
    else
    begin
        IF_ID_IR <= #2 Mem[PC];
        IF_ID_NPC <=#2 PC+1;
        PC <=#2 PC+1;                        //PC==NPC
    end
end
end

//ID STAGE
always@(posedge clk2)begin
if(HALTED==0)
begin
    if(IF_ID_IR[25:21]==5'b00000) ID_EX_A <= 0;
    else ID_EX_A <= #2 Reg[IF_ID_IR[25:21]];   //rs
    
    if(IF_ID_IR[20:16]==5'b00000) ID_EX_B <= 0;
    else ID_EX_B <= #2 Reg[IF_ID_IR[20:16]];   //rt

 ID_EX_NPC <= #2 IF_ID_NPC;
 ID_EX_IR <= #2 IF_ID_IR;
 ID_EX_IMM <= #2 {{16{IF_ID_IR[15]}},{IF_ID_IR[15:0]}};

case(IF_ID_IR[31:26])
  ADD,SUB,MUL,AND,OR,SLT: ID_EX_TYPE <= #2 RR_ALU; //reg-reg operation
  ADI,SBI,SLTI:ID_EX_TYPE <= #2 RM_ALU;           //reg-mem operation
  BEQZ,BNEQZ: ID_EX_TYPE <= #2 BRANCH;             //branch operation
  HLT: ID_EX_TYPE <= #2 HALT;
  LW: ID_EX_TYPE <= #2 LOAD;
  SW: ID_EX_TYPE <= #2 STORE;
  default:ID_EX_TYPE <= #2 HALT;                   //inavalid opcode
endcase
end
end

//EX STAGE
always@(posedge clk1)begin
if(HALTED==0)
    begin
    EX_MEM_IR <=#2 ID_EX_IR;
    EX_MEM_TYPE <= #2 ID_EX_TYPE;
    T_BRANCH<= #2 0;

    case(EX_MEM_TYPE)
    RR_ALU:begin
        case(ID_EX_IR[31:26])
        ADD: EX_MEM_ALUOUT <= #2 ID_EX_A + ID_EX_B;
        SUB: EX_MEM_ALUOUT <= #2 ID_EX_A - ID_EX_B;
        MUL: EX_MEM_ALUOUT <= #2 ID_EX_A * ID_EX_B;
        AND: EX_MEM_ALUOUT <= #2 ID_EX_A & ID_EX_B;
        OR: EX_MEM_ALUOUT <= #2 ID_EX_A | ID_EX_B;
        SLT: EX_MEM_ALUOUT <= #2 ID_EX_A < ID_EX_B;
        default: EX_MEM_ALUOUT <= #2 32'hxxxxxxxx;
        endcase
    end

    RM_ALU:begin
        case(ID_EX_IR[31:26])
        ADI:EX_MEM_ALUOUT <= #2 ID_EX_A + ID_EX_IMM;
        SBI:EX_MEM_ALUOUT <= #2 ID_EX_A - ID_EX_IMM;
        SLTI:EX_MEM_ALUOUT <= #2 ID_EX_A < ID_EX_IMM;
        default: EX_MEM_ALUOUT <= #2 32'hxxxxxxxx;
        endcase
    end

    BRANCH:begin
        EX_MEM_ALUOUT<= #2 ID_EX_NPC + ID_EX_IMM;
        EX_MEM_COND<= #2 (ID_EX_A==0);
    end

    LOAD,STORE:begin
        EX_MEM_ALUOUT<= #2 ID_EX_A + ID_EX_IMM;
        EX_MEM_B<= #2 ID_EX_B;
    end
    endcase
    end
end


//MEM STAGE
always@(posedge clk2)
begin
if(HALTED==0)begin
    MEM_WB_IR <= #2 EX_MEM_IR;
    MEM_WB_TYPE <= #2 EX_MEM_TYPE;
    case(MEM_WB_TYPE)
        RR_ALU,RM_ALU: MEM_WB_ALUOUT <= #2 EX_MEM_ALUOUT;
        LOAD:MEM_WB_LMD <= #2 Mem[EX_MEM_ALUOUT];
        STORE:
        begin
            if (T_BRANCH==0) begin
                Mem[MEM_WB_ALUOUT] <= #2 EX_MEM_B;
            end
        end
    endcase
end
end

//WB STAGE
always@(posedge clk1)begin
if (T_BRANCH == 0 || MEM_WB_TYPE != BRANCH)    //if branch is taken write is disabled
begin
    case(MEM_WB_TYPE)
    RR_ALU:Reg[MEM_WB_IR[15:11]]<= #2 MEM_WB_ALUOUT;      //rd
    RM_ALU:Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUOUT;      //rt
    LOAD: Reg[MEM_WB_IR[20:16]]<= #2 MEM_WB_LMD;         //loaded into the register bank,rt
    HALT:HALTED<= #2 1'b1;
    endcase
end
end
endmodule