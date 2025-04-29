`timescale 1ns/10ps
`include "Memory.v"

`ifdef syn
`include "tsmc18.v"
`include "CPU_syn.v"
`else
`include "CPU.v"
`endif 

`define CYCLE 10

module testbench;

// Declare parameters
parameter WIDTH = 32; // Width of data paths
parameter ADDRSIZE = 32; // Size of address field

reg clk, rst; // clock, reset

wire [WIDTH-1:0] datamem_data_out; // data memory
wire [ADDRSIZE-1:0] datamem_addr; // data memory address
wire [WIDTH-1:0] datamem_data_in; // data to write in memory
wire datamem_mem_r;
wire datamem_mem_w;

wire [WIDTH-1:0] instmem_data_out; // instruction
wire instmem_mem_r;
wire [ADDRSIZE-1:0] instmem_addr; // program counter

wire datamem_done;

CPU u_CPU(.clk(clk), .rst(rst),
          .ex_mem_mem_data(datamem_data_out), .mem_wb_mem_addr(datamem_addr), .mem_wb_mem_data(datamem_data_in), .dmem_read(datamem_mem_r), .dmem_write(datamem_mem_w),
          .inst_in(instmem_data_out), .mem_read_i(instmem_mem_r), .mem_addr_i(instmem_addr), .mem_done(datamem_done));

Memory u_datamem(.clk(clk), .rst(rst), .data_in(datamem_data_in), .data_out(datamem_data_out), .data_addr(datamem_addr),
                 .mem_r(datamem_mem_r), .mem_w(datamem_mem_w), .mem_done(datamem_done));

Memory u_instmem(.clk(clk), .rst(rst), .data_in(32'b0), .data_out(instmem_data_out), .data_addr(instmem_addr), 
               .mem_r(instmem_mem_r), .mem_w(1'b0), .mem_done());

`ifdef syn
	initial $sdf_annotate("CPU_syn.sdf", u_CPU);
`endif

initial begin
  #(`CYCLE*2.7)
  $readmemb("sisc.prog", u_instmem.MEM);
end


initial begin
  clk = 1;
  rst = 1;
  #(`CYCLE*2.5) rst = 0;
end

initial begin #10000
	$finish;
end

always begin #(`CYCLE/2) clk = ~clk ; end  //clock generation 

initial begin
    $dumpfile("CPU.fsdb");
    $dumpvars;
end

endmodule
