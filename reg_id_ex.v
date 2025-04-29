`include "defines.v"

module reg_id_ex(
//------------------inputs------------------
input                 clk,
input                 rst,
input [         1:0]  stall,
input [   `AluOpBus]  id_aluop,
input [  `AluSelBus]  id_alusel,
input [     `RegBus]  id_opv1,
input [     `RegBus]  id_opv2,
input [ `RegAddrBus]  id_reg_waddr,
input                 id_we,
input [`InstAddrBus]  id_link_addr,
input [     `RegBus]  id_mem_offset,
//------------------outputs------------------
output reg [   `AluOpBus] ex_aluop,
output reg [  `AluSelBus] ex_alusel,
output reg [     `RegBus] ex_opv1,
output reg [     `RegBus] ex_opv2,
output reg [ `RegAddrBus] ex_reg_waddr,
output reg                ex_we,
output reg [`InstAddrBus] ex_link_addr,
output reg [     `RegBus] ex_mem_offset
);
//-------------------------------------------
always @ (posedge clk) begin
    if (rst || (stall[0] && !stall[1])) begin
	// if hazard at state_id => bubble
        ex_aluop      <= `EXE_NOP_OP;
        ex_alusel     <= `EXE_RES_NOP;
        ex_opv1       <= 0;
        ex_opv2       <= 0;
        ex_reg_waddr  <= 0;
        ex_we         <= 0;
        ex_link_addr  <= 0;
        ex_mem_offset <= 0;
    end
	/*
	else if(stall[0])begin
		ex_aluop      <= ex_aluop;
        ex_alusel     <= ex_alusel;
        ex_opv1       <= ex_opv1;
        ex_opv2       <= ex_opv2;
        ex_reg_waddr  <= ex_reg_waddr;
        ex_we         <= ex_we;
        ex_link_addr  <= ex_link_addr;
        ex_mem_offset <= ex_mem_offset;
	
	end
	*/
	else if(!stall[0]) begin
        ex_aluop      <= id_aluop;
        ex_alusel     <= id_alusel;
        ex_opv1       <= id_opv1;
        ex_opv2       <= id_opv2;
        ex_reg_waddr  <= id_reg_waddr;
        ex_we         <= id_we;
        ex_link_addr  <= id_link_addr;
        ex_mem_offset <= id_mem_offset;
    end
	// if hazard at state_mem => stay the same
end

endmodule
