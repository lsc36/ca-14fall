module adder16(CAR_OUT,ADDER_OUT,SRCA,SRCB,CAR_IN);
	input CAR_IN;
	input [15:0]SRCA,SRCB;
	output [15:0]ADDER_OUT;
	output CAR_OUT;
	reg [15:0]ADDER_OUT;
	reg CAR_OUT;
	reg [16:0]I;
	
	always@(SRCA or SRCB)
	begin
		I=SRCA+SRCB+CAR_IN;
		ADDER_OUT=I[15:0];
		CAR_OUT=I[16];
	end
endmodule