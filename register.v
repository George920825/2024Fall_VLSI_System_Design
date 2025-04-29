`include "defines.v"

module register(

input                     clk   ,
input                     rst   ,
input                     we    ,
input       [`RegAddrBus] waddr ,
input       [    `RegBus] wdata ,
input                        re1,
input       [`RegAddrBus] raddr1,
output reg  [    `RegBus] rdata1,
input                        re2,
input       [`RegAddrBus] raddr2,
output reg  [    `RegBus] rdata2
);

reg [`RegBus] regs [0:`RegNum-1];

integer i;

// write back
always @ (posedge clk) begin
	// asynchronous reset
	if(rst)begin
		for(i=0;i<`RegNum;i=i+1)begin
			//if(i!=0)
				regs[i] <= 0;
		end		
	end	
	else begin
		// x0 cannot be written
		if (we && waddr != 0)begin
			//$display("WRITE REGISTER FILE: x%d = %h", waddr, wdata);
			regs[waddr] <= wdata;
		end	
	end
end

// read 1
always @ (*) begin
	if (rst || !re1 || raddr1==0) 
		rdata1 = 0;
	else if (we && raddr1==waddr)// data forwarding
		rdata1 = wdata;
	else 
		rdata1 = regs[raddr1];
end

// read 2
always @ (*) begin
	if (rst || !re2 || raddr2==0) 
		rdata2 = 0;
	else if (we && raddr2==waddr)// data forwarding
		rdata2 = wdata;
	else 
		rdata2 = regs[raddr2];
end

endmodule // regfile