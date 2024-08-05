.PHONY: install

nand_dumper: nand_dumper.c
	$(CC) $< -o $@ -D_FILE_OFFSET_BITS=64

install: nand_dumper
	mkdir -pv $(out)/bin
	cp nand_dumper $(out)/bin/
