module	adder_test;
	reg	CAR_IN;
	reg	[15:0]SRCA,SRCB;
	wire	CAR_OUT;
	wire	[15:0]ADDER_OUT;
	adder16	Adder(CAR_OUT,ADDER_OUT,SRCA,SRCB,CAR_IN);

	initial
	begin:textfixture
	integer	j,k;
	
	CAR_IN	= 1;
	SRCA	= 0;
	SRCB	= 0;
	
	for(j=0;j<3;j=j+1)
		begin
			SRCA = j;
			for(k=0;k<3;k=k+1)
			begin
				SRCB = k;
				#10;
				CAR_IN = ~CAR_IN;
				$display("SRCA = %d, SRCB = %d, CAR_IN = %d, CAR_OUT = %d, ADDER_OUT =%d",SRCA,SRCB,CAR_IN,ADDER_OUT,CAR_OUT);
			end
		end
	
	for(j=32765;j<32769;j=j+1)
		begin
			SRCA = j;
			for(k=32765;k<32769;k=k+1)
			begin
				SRCB = k;
				#10;
				CAR_IN = ~CAR_IN;
				$display("SRCA = %d, SRCB = %d, CAR_IN = %d, CAR_OUT = %d, ADDER_OUT =%d",SRCA,SRCB,CAR_IN,ADDER_OUT,CAR_OUT);
			end
		end

	$stop;
	end
endmodule