module stall_ctrl (
	input  wire       rst         ,
	input  wire       stallreq_id ,
	input  wire       stallreq_mem,
	output reg  [1:0] stall
);

// stall[0] => ID
// stall[1] => MEM



	always @ (*) begin
		if(rst) begin
			stall = 2'b00;
		end 
		else if (stallreq_mem) begin
			stall = 2'b11;
		end
		else if (stallreq_id) begin
			stall = 2'b01;
		end 
		else begin
			stall = 2'b00;
		end
	end // always @ (*)

endmodule
