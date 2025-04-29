module reg_mem_wb(
input clk,
input rst,
input [4:0] addr_i,
input [31:0] data_i,
input we_i,
input [1:0] stall,

output reg [4:0] addr_o,
output reg [31:0] data_o,
output reg we_o
);

	//addr_o
	always@(posedge clk)begin
		if(rst)addr_o<=0;
		else if(stall[1]) addr_o<=0;
		else addr_o<=addr_i;
	end
	
	//data_o
	always@(posedge clk)begin
		if(rst)data_o<=0;
		else if(stall[1]) data_o<=0;
		else data_o<=data_i;
	end
	
	//we_o
	always@(posedge clk)begin
		if(rst)we_o<=0;
		else if(stall[1]) we_o<=0;
		else we_o<=we_i;
	end

endmodule	
	