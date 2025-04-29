`include "defines.v"

module reg_ex_mem (
    input clk,
    input rst,
    input [`RegAddrBus] ex_reg_waddr,
    input ex_we,
    input [`RegBus] ex_reg_wdata,
    input [1:0] stall,
    input [`MemAddrBus] ex_mem_addr,
    input [`AluOpBus] ex_aluop,
    input [`RegBus] ex_rt_data,
    output reg [`RegAddrBus] mem_reg_waddr,
    output reg mem_we,
    output reg [`RegBus] mem_reg_wdata,
    output reg [`MemAddrBus] mem_mem_addr,
    output reg [`AluOpBus] mem_aluop,
    output reg [`RegBus] mem_rt_data
);

    always @(posedge clk) begin
        if (rst) begin
            mem_reg_waddr <= 0;
            mem_we <= 0;
            mem_reg_wdata <= 0;
            mem_mem_addr <= 0;
            mem_aluop <= 0;
            mem_rt_data <= 0;
        end 
		else if(stall[1])begin
			mem_reg_waddr <= mem_reg_waddr;
            mem_we <= mem_we;
            mem_reg_wdata <= mem_reg_wdata;
            mem_mem_addr <= mem_mem_addr;
            mem_aluop <= mem_aluop;
            mem_rt_data <= mem_rt_data;
		
		end
		else  begin
            mem_reg_waddr <= ex_reg_waddr;
            mem_we <= ex_we;
            mem_reg_wdata <= ex_reg_wdata;
            mem_mem_addr <= ex_mem_addr;
            mem_aluop <= ex_aluop;
            mem_rt_data <= ex_rt_data;
        end
    end
endmodule
