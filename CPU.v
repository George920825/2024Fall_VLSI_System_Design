`include "defines.v"
`include "stall_ctrl.v"
`include "pc_reg.v"
`include "stage_if.v"
`include "reg_if_id.v"
`include "stage_id.v"
`include "register.v"
`include "reg_id_ex.v"
`include "stage_ex.v"
`include "reg_ex_mem.v"
`include "stage_mem.v"
`include "reg_mem_wb.v"

module CPU(
input clk, rst,
// instruction memory
input [31:0] inst_in,
//input mem_busy_i,
output mem_read_i,
output [31:0] mem_addr_i,
// data memory
input [31:0] ex_mem_mem_data,
input mem_done,
//input dmem_busy,
output [31:0] mem_wb_mem_addr,
output [31:0] mem_wb_mem_data,
output dmem_read,
output dmem_write
);

wire stallreq_id ;
wire stallreq_mem;
wire [1:0] stall ;

stall_ctrl stall_ctrl0 (
		// input
		.rst         (rst         ),
		.stallreq_id (stallreq_id ),
		.stallreq_mem(stallreq_mem),
		// output
		.stall       (stall       )
);

//stage_id ----> pc reg
wire br;
wire [31:0] br_addr;

//reg_pc 
wire [31:0]pc_if_pc;
wire br_wait;

//stage_if
//wire [31:0] inst_in;
//wire mem_busy_i;
//wire mem_read_i;
//wire [31:0] mem_addr_i
wire [31:0] if_reg_pc;
wire [31:0] if_reg_inst;

pc_reg reg_pc0(
		.clk(clk),
		.rst(rst),
		.stall(stall[0]),
		.br(br),
		.br_addr(br_addr),
		.pc(pc_if_pc),
		.br_wait(br_wait)
);



stage_if stage_if0(
		.rst(rst),
		.pc_i(pc_if_pc),
		.inst_in(inst_in),
		//.mem_busy(mem_busy_i),
		.br(br),
		.br_wait(br_wait),
		.mem_read(mem_read_i),
		.mem_addr(mem_addr_i),
		.pc_o(if_reg_pc),
		.inst_out(if_reg_inst)
);

// reg_if_id -----> stage_id
wire [31:0] id_pc;
wire [31:0] id_inst;

reg_if_id reg_if_id0(
		.clk(clk),
		.rst(rst),
		.if_pc(if_reg_pc),
		.if_inst(if_reg_inst),
		.br(br),
		.stall(stall),
		.id_pc(id_pc),
		.id_inst(id_inst)
);


// register
wire wb_we;
wire re1, re2;
wire [31:0] wb_data;
wire [4:0]  wb_addr;
wire [31:0] rdata1, rdata2;
wire [4:0]  raddr1, raddr2;

register register0 (.clk (clk), 
					.rst (rst),
					.we (wb_we), 
					.re1 (re1),
					.re2 (re2),					  
					.waddr (wb_addr), 
					.wdata (wb_data),
					.rdata1 (rdata1),
					.rdata2 (rdata2),
					.raddr1 (raddr1),
					.raddr2 (raddr2)
					);


//stage_id ----> reg_id_ex
wire [7:0] id_aluop;
wire [2:0] id_alusel;
wire [31:0] id_opv1, id_opv2;
wire [4:0] id_reg_waddr;
wire id_we;
wire [31:0] id_link_addr;
wire [31:0] id_mem_offset;

wire [4:0] ex_reg_waddr_o;
wire ex_we_o;
wire [31:0] ex_reg_wdata;
wire [7:0] ex_aluop_o;

wire [4:0] mem_wb_reg_addr;
wire [31:0] mem_wb_reg_data;
wire mem_wb_we;

stage_id stage_id0 (.rst (rst),
					.pc (id_pc),
					.inst (id_inst),
					.reg_data1 (rdata1),
					.reg_data2 (rdata2),
					.reg_en1 (re1),
					.reg_en2 (re2),
					.reg_addr1 (raddr1),
					.reg_addr2 (raddr2),
					.ex_aluop (ex_aluop_o),
					.ex_we (ex_we_o),
					.ex_reg_wdata (ex_reg_wdata),
					.ex_reg_waddr (ex_reg_waddr_o),
					.mem_we (mem_wb_we),
					.mem_reg_wdata (mem_wb_reg_data),
					.mem_reg_waddr (mem_wb_reg_addr),	
					.aluop (id_aluop),
					.alusel (id_alusel),
					.opv1 (id_opv1),
					.opv2 (id_opv2),
					.we (id_we),
					.reg_waddr (id_reg_waddr),
					.stallreq (stallreq_id),
					.br (br),
					.br_addr (br_addr),
					.link_addr (id_link_addr),
					.mem_offset (id_mem_offset)
				    );


// reg_id_ex ----> stage_ex
wire [7:0] ex_aluop;
wire [2:0] ex_alusel;
wire [31:0] ex_opv1, ex_opv2;
wire [4:0] ex_reg_waddr;
wire ex_we;
wire [31:0] ex_link_addr;
wire [31:0] ex_mem_offset;

reg_id_ex reg_id_ex0(.clk (clk), 
					 .rst (rst),
					 .stall (stall),
					 .id_aluop (id_aluop),
					 .id_alusel (id_alusel),
					 .id_opv1 (id_opv1),
					 .id_opv2 (id_opv2),
					 .id_reg_waddr(id_reg_waddr),
					 .id_we (id_we),
					 .id_link_addr (id_link_addr),
					 .id_mem_offset (id_mem_offset),
					 .ex_aluop (ex_aluop),
					 .ex_alusel (ex_alusel),
					 .ex_opv1 (ex_opv1),
					 .ex_opv2 (ex_opv2),
					 .ex_reg_waddr (ex_reg_waddr),
					 .ex_we (ex_we),
					 .ex_link_addr (ex_link_addr),
					 .ex_mem_offset (ex_mem_offset)
					);
					
// stage_ex ---> reg_ex_mem
//wire [4:0] ex_reg_waddr_o;
//wire ex_we_o;
//wire [31:0] ex_reg_wdata;
//wire [7:0] ex_aluop_o;
wire [31:0] ex_mem_addr;
wire [31:0] ex_rt_data;

stage_ex stage_ex0 (.rst(rst),
					.aluop(ex_aluop),
					.alusel(ex_alusel),
					.opv1 (ex_opv1),
					.opv2 (ex_opv2),
					.reg_waddr_i(ex_reg_waddr),
					.we_i (ex_we),
					.link_addr (ex_link_addr),
					.mem_offset (ex_mem_offset),
					.reg_waddr_o(ex_reg_waddr_o),
					.we_o(ex_we_o),
					.reg_wdata(ex_reg_wdata),
					.mem_addr(ex_mem_addr),
					.ex_aluop(ex_aluop_o),
					.rt_data(ex_rt_data)
					);

//stage mem input
wire [4:0] ex_mem_reg_addr;
wire [31:0] ex_mem_reg_data;
wire [31:0] ex_mem_mem_addr;
//wire [31:0] ex_mem_mem_data;
wire [31:0] ex_mem_store_data;
wire [7:0] ex_mem_opcode;
//wire dmem_busy;
wire ex_mem_we;
					
reg_ex_mem reg_ex_mem0 (.clk(clk),
						.rst(rst),
						.ex_reg_waddr(ex_reg_waddr_o),
						.ex_we(ex_we_o),
						.ex_reg_wdata(ex_reg_wdata),
						.stall(stall),
						.ex_mem_addr(ex_mem_addr),
						.ex_aluop(ex_aluop_o),
						.ex_rt_data(ex_rt_data),
						.mem_reg_waddr(ex_mem_reg_addr),
						.mem_we(ex_mem_we),
						.mem_reg_wdata(ex_mem_reg_data),
						.mem_mem_addr(ex_mem_mem_addr),
						.mem_aluop(ex_mem_opcode),
						.mem_rt_data(ex_mem_store_data)
						);



//stage mem output & reg_mem_wb input
//wire [4:0] mem_wb_reg_addr;
//wire [31:0] mem_wb_reg_data;
//wire mem_wb_we;
//wire [31:0] mem_wb_mem_addr;
//wire [31:0] mem_wb_mem_data;
//wire dmem_read;
//wire dmem_write;
// wire [5:0] stall;


//reg_mem_wb output
//wire [4:0] wb_addr;
//wire [31:0] wb_data;
//wire wb_we;
//wire mem_done;


stage_mem stage_mem1(
		.rst(rst), 
		.reg_addr_i(ex_mem_reg_addr), 
		.reg_data_i(ex_mem_reg_data), 
		.mem_addr_i(ex_mem_mem_addr), 
		.mem_data_i(ex_mem_mem_data), 
		.store_data(ex_mem_store_data),
		.opcode(ex_mem_opcode), 
		.we_i(ex_mem_we),
		.reg_addr_o(mem_wb_reg_addr),
		.reg_data_o(mem_wb_reg_data),
		.mem_addr_o(mem_wb_mem_addr),
		.mem_data_o(mem_wb_mem_data),
		.mem_read(dmem_read),
		.mem_write(dmem_write),
		.we_o(mem_wb_we),
		.stall(stallreq_mem),
		.mem_done(mem_done)
);

reg_mem_wb reg_mem_wb1(
		.clk(clk), 
		.rst(rst), 
		.addr_i(mem_wb_reg_addr), 
		.data_i(mem_wb_reg_data), 
		.we_i(mem_wb_we),
		.stall(stall), 
		.addr_o(wb_addr), 
		.data_o(wb_data), 
		.we_o(wb_we)	
);

endmodule

