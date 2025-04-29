`define Inst 31:0
`define InstAddr 31:0
module stage_if(rst,pc_i,inst_in,br,br_wait,mem_read,mem_addr,pc_o,inst_out);

input rst;
input [`InstAddr]pc_i;
input [`Inst] inst_in;
//input mem_busy;
input br;
input br_wait; // from pc_reg(after it receive br)

output reg mem_read;
output reg [`InstAddr]mem_addr;
output reg [`InstAddr]pc_o;
output reg [`Inst] inst_out;
//output reg stall;

reg wait_one; // 0->1 when receive br 
//reg mem_access;

always@(*)begin
  if(br && br_wait!=1)wait_one=1;
  else if(br_wait)wait_one=0;
  else wait_one=0;
end

always@(*)begin
  if(!wait_one && !br_wait) begin
    inst_out=inst_in;
  end
  else begin 
    inst_out=0;
  end
end

always@(*)begin
  if(!wait_one) pc_o=pc_i - 1;
  else pc_o=0;
end

// always@(*)begin
//  if(!wait_one && !mem_busy && mem_access) inst_out=inst_in;
//  else inst_out=0;
// end

// always@(*)begin
//  if(!wait_one && !mem_busy && !mem_access) stall=1;
//  else if(!wait_one && !mem_busy && mem_access) stall=0;
//  else if(!wait_one && mem_busy) stall=1;
//  else stall=0;
// end

always@(*)begin
  if(!wait_one)mem_addr=pc_i;
  else mem_addr=0;
end

always@(*)begin
  if(rst)mem_read=0;
  else if(!wait_one)mem_read=1;
  else mem_read=0;
end

endmodule
