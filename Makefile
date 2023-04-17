binary:
	dune build src/XpatSolver.exe

byte:
	dune build src/XpatSolver.bc

clean:
	dune clean

clean_all:
	dune clean
	rm -rf solution_file

test:
	dune runtest

summary:
	@./test-summary
