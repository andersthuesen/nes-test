all:
	ca65 -t nes src/main.s -o obj/main.o
	ld65 -t nes obj/main.o -o rom.nes

clean:
	rm obj/main.o
	rm rom.nes
