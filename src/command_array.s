; Array dei comandi
;
; by lurenault
;


CMDARRAY:

PRINTARRAY:
	.word PEEKARRAY
	.word $0000
	.word $0000
	.byte 5
	.byte 1
	.byte "print"
	.byte "?"

PEEKARRAY:
	.word POKEARRAY		; Comando PEEK
	.word $0001
	.word $0000
	.byte 4
	.byte 2
	.byte "peek"
	.byte "pE"

POKEARRAY:
	.word $0000		; Comando POKE
	.word $0002
	.byte 4
	.byte 2
	.byte "poke"
	.byte "pO"
	
