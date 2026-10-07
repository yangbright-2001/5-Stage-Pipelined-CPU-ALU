// flags: 3-bit alu flag
// flags[2] : zero flag
// flags[1] : negative flag
// flags[0] : overflow flag 

module ALU (
input[31:0] src_AE,
input[31:0] src_BE,
input [4:0] alu_control,
output reg[31:0] alu_out_e,
output reg[2:0] reg_flag);

reg[31:0] tmp;

localparam 
    ADD = 0,
    ADDU = 1,
    SUB = 2,
    SUBU = 3,
    AND = 4,
    NOR = 5,
    OR = 6,
    XOR = 7,
    SLL = 8,
    SLLV = 9,
    SRL = 10,
    SRLV = 11,
    SRA = 12,
    SRAV = 13,
    SLT = 14,
    JR = 15,
    ADDI = 16,
    ADDIU = 17,
    ANDI = 18,
    ORI = 19,
    BEQ = 20,
    BNE = 21,
    LW = 22,
    SW = 23,
    J = 24,
    JAL = 25,
    XORI = 26;

always @(src_AE, src_BE, alu_control) begin   

    case (alu_control)
        ADD, ADDI, LW, SW, JAL: begin        //add
            alu_out_e = src_AE + src_BE;
            // $display("Here comes ADDI");
            if ( (src_AE[31]==0 && src_BE[31]==0 && alu_out_e[31]==1) || (src_AE[31]==1 && src_BE[31]==1 && alu_out_e[31]==0) ) begin
                reg_flag = 3'b001;
            end
            else begin
                reg_flag = 3'b000;
            end
        end

        ADDU, ADDIU: begin        //addu
            alu_out_e = src_AE + src_BE;
            reg_flag = 3'b000;
        end

        SUB: begin        //sub,要考虑顺序问题，分清rs和rt具体存在哪个reg里面
            alu_out_e = src_AE - src_BE;
            $display("here comes sub, src_AE:%d, src_BE:%d, alu_out_e: %d",src_AE, src_BE, alu_out_e);
            if ( (src_AE[31]==0 && src_BE[31]==1 && alu_out_e[31]==1) || (src_AE[31]==1 && src_BE[31]==0 && alu_out_e[31]==0) ) begin
                reg_flag = 3'b001;
            end
            else begin
                reg_flag = 3'b000;
            end

        end

        SUBU: begin        //subu
            alu_out_e = src_AE - src_BE;
            reg_flag = 3'b000;
        end

        AND, ANDI: begin        //and
            alu_out_e = src_AE & src_BE;
            reg_flag = 3'b000;
        end
        
        NOR: begin        //nor
            alu_out_e = ~(src_AE | src_BE);
            reg_flag = 3'b000;
        end

        OR, ORI: begin        //or
            alu_out_e = src_AE | src_BE;
            reg_flag = 3'b000;
        end

        XOR, XORI: begin        //xor
            alu_out_e = src_AE ^ src_BE;
            reg_flag = 3'b000;
        end

        SLT: begin        //slt
            tmp = src_AE - src_BE;
            alu_out_e = tmp[31];
            if (alu_out_e == 1) begin
                reg_flag = 3'b010;
            end
            else begin
                reg_flag = 3'b000;
            end
        end

        SLL: begin        //sll:rt左移shamt个位置，然后把结果存到rd，域rs被忽略
            alu_out_e = src_BE << src_AE;
            reg_flag = 3'b000;
        end

        SLLV: begin        //sllv:rt左移shamp个位置，然后把结果存到rd
            alu_out_e = src_BE << src_AE[3:0];
            reg_flag = 3'b000;
        end

        SRL: begin        //srl:rt右移shamt个位置，然后把结果存到rd，域rs被忽略
            alu_out_e = src_BE >> src_AE;
            reg_flag = 3'b000;
        end

        SRLV: begin        //srlv:rt右移rd个位置，然后把结果存到rd
            alu_out_e = src_BE >> src_AE[3:0];
            reg_flag = 3'b000;
        end

        SRA: begin        //sra:rt算术右移shamt个位置，然后把结果存到rd，域rs被忽略
            alu_out_e = $signed(src_BE) >>> src_AE;
            reg_flag = 3'b000;
        end

        SRAV: begin        //srav:rt算术右移rd个位置，然后把结果存到rd
            alu_out_e = $signed(src_BE) >>> src_AE[3:0];
            reg_flag = 3'b000;
        end

        BEQ: begin
            if (src_AE == src_BE) begin
                alu_out_e = 1;
                reg_flag = 3'b100;
            end
            else begin
                alu_out_e = 0;
                reg_flag = 3'b000;
            end
        end

        BNE: begin
            if (src_AE != src_BE) begin
                alu_out_e = 1;
                reg_flag = 3'b100;
            end
            else begin
                alu_out_e = 0;
                reg_flag = 3'b000;
            end
        end

    endcase
end

endmodule
