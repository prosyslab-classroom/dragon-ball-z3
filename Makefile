MAKE=@make
DUNE=@dune
LN=@ln -sf
RM=@rm
EXE=dbz3

all:
	$(DUNE) build src/main.exe
	$(LN) _build/default/src/main.exe $(EXE)

clean:
	$(DUNE) clean
	$(RM) -rf $(EXE)
