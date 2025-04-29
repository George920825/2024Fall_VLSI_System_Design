`define LB 20
`define LH 21
`define LW 22
`define LBU 23
`define LHU 24
`define SB 25
`define SH 26
`define SW 27

module stage_mem(
input rst,
input [4:0] reg_addr_i,
input [31:0] reg_data_i,
input [31:0] mem_addr_i,
input [31:0] mem_data_i,
input [31:0] store_data,
input [7:0] opcode,
//input mem_busy,
input we_i,
input mem_done,

output reg [4:0] reg_addr_o,
output reg [31:0] reg_data_o,
output reg [31:0] mem_addr_o,
output reg [31:0] mem_data_o,
output reg mem_read,
output reg mem_write,
output reg we_o,
output reg stall
);

//reg mem_taking;
	
	//reg_addr_o
	always@(*)begin
		if(rst)reg_addr_o=0;
		else reg_addr_o=reg_addr_i;	
	end

	//reg_data_o
	always@(*)begin
		if(rst)reg_data_o=0;
		else begin
			case(opcode)
				`SB,`SH,`SW:reg_data_o=0;
				`LB:reg_data_o={{24{mem_data_i[7]}},mem_data_i[7:0]};
				`LH:reg_data_o={{16{mem_data_i[7]}},mem_data_i[15:0]};
				`LW:reg_data_o=mem_data_i;
				`LBU:reg_data_o={{24{1'b0}},mem_data_i[7:0]};
				`LHU:reg_data_o={{16{1'b0}},mem_data_i[15:0]};
				default:reg_data_o=reg_data_i;
			endcase
		end
	end
	
	//mem_addr_o
	always@(*)begin
		if(rst)mem_addr_o=0;
		else mem_addr_o=mem_addr_i;
	end
	
	//mem_data_o
	always@(*)begin
		if(rst)mem_data_o=0;
		else begin
			case(opcode)
				`SB:mem_data_o={4{store_data[7:0]}};
				`SH:mem_data_o={2{store_data[15:0]}};
				`SW:mem_data_o=store_data;
				default:mem_data_o=0;
			endcase	
		end
	end
	
	//mem_read
	always@(*)begin
		if(rst)mem_read=0;
		else if(mem_done)mem_read=0;
		else begin
			case(opcode)
				`LB,`LH,`LW,`LBU,`LHU:mem_read=1;
				default:mem_read=0;
			endcase
		end
	end
	
	//mem_write
	always@(*)begin
		if(rst)mem_write=0;
		else begin
			case(opcode)
				`SB,`SH,`SW:mem_write=1;
				default:mem_write=0;
			endcase
		end
	end
	
	//we_o
	always@(*)begin
		if(rst)we_o=0;
		else we_o=we_i;
	end
	
	//stall
	always@(*)begin
		if(rst)stall=0;
		else if(mem_done)stall=0;
		else begin
			case(opcode)
				`LB,`LH,`LW,`LBU,`LHU:stall=1;
				default:stall=0;
			endcase
		end
	end
	
	//mem_taking
	/*always@(*)begin
		if(rst)mem_taking=0;
		else if(!mem_busy && !mem_taking)begin
			case(opcode)
				`LB,`LH,`LW,`LBU,`LHU:mem_taking=1;
				default:mem_taking=0;
			endcase
		end
		else if(!mem_busy && mem_taking) mem_taking=0;
		else mem_taking=0;
	end*/
	
endmodule
