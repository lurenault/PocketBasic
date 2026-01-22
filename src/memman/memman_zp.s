; Memory manager zeropage variables
; MUST BE INCLUDED IN ZEROPAGE

MEMBOTTOM:
	.res 2	; Puntatore di memoria al primo indirizzo disponibile dal basso della memoria

MEMTOP:
	.res 2	; Puntatore di memoria all'ultimo indirizzo (+1) disponibile dall'alto della memoria

FIRSTENTRY:
	.res 2	; Puntatore di memoria alla prima variabile salvata in memoria ( = 0 se è la prima )
