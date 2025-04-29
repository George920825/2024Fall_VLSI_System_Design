`include "defines.v"

module stage_ex (
    input rst,
    input [`AluOpBus] aluop,
    input [`AluSelBus] alusel,
    input [`RegBus] opv1,
    input [`RegBus] opv2,
    input [`RegAddrBus] reg_waddr_i,
    input we_i,
    input [`InstAddrBus] link_addr,
    input [`RegBus] mem_offset,
    output reg [`RegAddrBus] reg_waddr_o,
    output reg we_o,
    output reg [`RegBus] reg_wdata,
    output reg [`MemAddrBus] mem_addr,
    output reg [`AluOpBus] ex_aluop,
    output reg [`RegBus] rt_data
);

    reg [`RegBus] logic_out;
    reg [`RegBus] shift_out;
    reg [`RegBus] arith_out;
    reg [`RegBus] mem_out;

    // EXE_RES_LOGIC
    always @(*) begin
        if (rst) begin
            logic_out = 0;
        end else begin
            case (aluop)
                `EXE_XOR_OP: begin
                    logic_out = opv1 ^ opv2;
                end
                `EXE_OR_OP: begin
                    logic_out = opv1 | opv2;
                end
                `EXE_AND_OP: begin
                    logic_out = opv1 & opv2;
                end
                default: begin
                    logic_out = 0;
                end
            endcase
        end
    end

    // EXE_RES_SHIFT
    always @(*) begin
        if (rst) begin
            shift_out = 0;
        end else begin
            case (aluop)
                `EXE_SLL_OP: begin
                    shift_out = opv1 << opv2[4:0];
                end
                `EXE_SRL_OP: begin
                    shift_out = opv1 >> opv2[4:0];
                end
                `EXE_SRA_OP: begin
                    shift_out = ({32{opv1[31]}} << {6'd32 - {1'b0, opv2[4:0]}}) | (opv1 >> opv2[4:0]);
                end
                default: begin
                    shift_out = 0;
                end
            endcase
        end
    end

    // EXE_RES_ARITH
    always @(*) begin
        if (rst) begin
            arith_out = 0;
        end else begin
            case (aluop)
                `EXE_ADD_OP: begin
                    arith_out = opv1 + opv2;
                end
                `EXE_SUB_OP: begin
                    arith_out = opv1 - opv2;
                end
                `EXE_SLT_OP: begin
                    arith_out = $signed(opv1) < $signed(opv2);
                end
                `EXE_SLTU_OP: begin
                    arith_out = opv1 < opv2;
				end
                default: begin
                    arith_out = 0;
                end
            endcase
        end
    end

    // EXE_RES_LOAD_STORE
    always @(*) begin
        if (rst || alusel != `EXE_RES_LOAD_STORE) begin
            mem_out = 0;
        end else begin
            mem_out = opv1 + mem_offset;
        end
    end

    // output
    always @(*) begin
        reg_waddr_o = reg_waddr_i;
        we_o = we_i;
        ex_aluop = aluop;
        rt_data = opv2;
        case (alusel)
            `EXE_RES_LOGIC: begin
                reg_wdata = logic_out;
                mem_addr = 0;
            end
            `EXE_RES_SHIFT: begin
                reg_wdata = shift_out;
                mem_addr = 0;
            end
            `EXE_RES_ARITH: begin
                reg_wdata = arith_out;
                mem_addr = 0;
            end
            `EXE_RES_JUMP_BRANCH: begin
                reg_wdata = link_addr;
                mem_addr = 0;
            end
            `EXE_RES_LOAD_STORE: begin
                reg_wdata = 0;
                mem_addr = mem_out;
            end
            default: begin
                reg_wdata = 0;
                mem_addr = 0;
            end
        endcase

    end

endmodule
