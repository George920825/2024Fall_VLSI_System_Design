module Memory(clk,rst,data_in,data_out,data_addr,mem_r,mem_w,mem_done);

//declare parameter
parameter WIDTH=32;
parameter ADDRSIZE=32;
parameter MEMSIZE=256;

integer i;

input clk,rst,mem_r,mem_w;
input [WIDTH-1:0] data_in; //store
input [ADDRSIZE-1:0] data_addr; //load

output reg [WIDTH-1:0]data_out; //load
output reg mem_done;
//output reg mem_busy;

reg [WIDTH-1:0] MEM [0:MEMSIZE-1];
//reg count;

always@(posedge clk)begin
	if(rst) data_out<=0;
	else if(mem_r)begin
		data_out<=MEM[data_addr];
	end
end

always@(posedge clk)begin
	if(rst)mem_done<=0;
	else if(mem_r)mem_done<=1;
	else mem_done<=0;
end


always@(posedge clk)begin
	if(rst)begin
		for(i=0;i<MEMSIZE;i=i+1)begin
			MEM[i]<=0;
		end
	end
	else if(mem_w)begin
		MEM[data_addr]<=data_in;
	end
end

/*
always@(*)begin
	if(count==1) mem_busy=0;
	else if(mem_r) mem_busy=1;
	else mem_busy=0;
end

always@(posedge clk)begin
	if(rst) count<=0;
	else if(mem_r)count<=1;
	else count<=0;
end
*/

endmodule



