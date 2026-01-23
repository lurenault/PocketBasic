; Memory manager zeropage variables
; MUST BE INCLUDED IN ZEROPAGE

.ifndef	MEMMANZP_H
MEMMANZP_H=1
.endif

MEMBOTTOM:
	.res 2	; Puntatore di memoria al primo indirizzo disponibile dal basso della memoria
MEMTOP:
	.res 2	; Puntatore di memoria all'ultimo indirizzo (+1) disponibile dall'alto della memoria
FIRSTENTRY:
	.res 2	; Puntatore di memoria alla prima variabile salvata in memoria ( = 0 se non ci sono variabili in memoria )
CURRVAR:
	.res 2	; Puntatore di memoria alla variabile corrente
MMTEMPP1:
	.res 2	; Puntatore di memoria temporaneo
MMTEMPP2:
	.res 2	; Puntatore di memoria temporaneo
MMNAMEPTR:
	.res 2	; Puntatore alla stringa contenente il nome della variabile da aggiungere/cercare
MMNAMELEN:
	.res 1	; Lunghezza del nome della variabile da aggiungere/cercare/modificare
MMVARTYPE:
	.res 1	; Tipo della variabile da aggiungere/cercare/modificare
MMBUFFLEN:
	.res 1			; Lunghezza buffer dei dati della variabile
MMBUFFPTR:
	.res 2			; Puntatore al buffer dei dati della variabile

; TOTALE:    19 byte
