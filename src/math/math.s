	;; PocketBasic	Mathematical Library v0.1
	;; by lurenault

	;; Struttura DAC (Double ACcumulator)
	;;=========================================
	;; Offset	Descrizione
	;; $00		Tipo di variabile
	;; $01-$04	Mantissa della variabile
	;; $05-$06	Esponente della variabile

	.ifndef	MATHZP_H
	.fatal	"Must include math_zp.s in zeropage segment!"
	.endif

	.out	"PocketBasic Mathematical Library by lurenault"

	.ifdef	MODE16
	.out	"16 bit version"
	.endif

	.include	"add.s"
	.include	"display.s"

FIXEXP:
	rts
