`define InstAddr 31:0
`define Inst 31:0

module reg_if_id(clk,rst,if_pc,if_inst,br,stall,id_pc,id_inst);
input clk,rst;
input [`InstAddr] if_pc;
input [`Inst] if_inst;
input br;
input [1:0]stall;
output reg [`InstAddr] id_pc;
output reg [`Inst] id_inst;


reg [`Inst] inst_temp;
reg use_temp;

always@(posedge clk)begin
	if(rst)begin
		inst_temp <= 0;
		use_temp <= 0;
	end	
	else if(stall[0])begin
		inst_temp <= if_inst;
		use_temp <= 1;
	end
	else begin
		inst_temp <= 0;
		use_temp <= 0;
	end
end


always@(posedge clk)begin
	if(rst || br) id_pc<=0;
	else if(stall[0]) id_pc <= id_pc;
	//else if(stall[0]) id_pc <= id_pc;
	else 	id_pc<=if_pc;
end

always@(posedge clk)begin
	if(rst || br) id_inst<=0;
	//else if(br || stall[0]) id_inst <= id_inst;
	else if(stall[0]) id_inst <= id_inst;
	else if(use_temp) id_inst <= inst_temp;
	else  id_inst<=if_inst;
end

endmodule