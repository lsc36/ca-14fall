ROOT_MODULE = TestBench
OUTFILE = main

all:
	iverilog -s $(ROOT_MODULE) -o $(OUTFILE) *.v

run:
	vvp -n $(OUTFILE)

clean:
	rm -f $(OUTFILE)
