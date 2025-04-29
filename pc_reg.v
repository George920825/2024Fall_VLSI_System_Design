`define InstAddr 31:0

module pc_reg(clk,rst,stall,br,br_addr,pc,br_wait);
input clk;
input rst;
input stall;
input br;
input [`InstAddr] br_addr;
output reg [`InstAddr]pc;
output reg br_wait;


always@(posedge clk or posedge rst)begin
	if(rst)pc<=32'd0;
	else if(br)pc<=br_addr;
	else if(stall)pc<=pc;
	else pc<=pc+32'd1;
end

always@(posedge clk)begin
	if(rst)br_wait<=1'd0;
	else if(br)br_wait<=1;
	else br_wait<=0;
end


endmodule
