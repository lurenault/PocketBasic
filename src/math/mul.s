	;; Moltiplicazione

IMUL:
	;; Moltiplicazione intera

	jsr	MINIMEXP	; Riduce gli esponenti al minimo

	;; Azzera MOR

	.if	.cap(CPU_HAS_STZ)

	stz	MOR
	stz	MOR+1
	stz	MOR+2
	stz	MOR+3
	stz	MOR+4
	stz	MOR+5
	stz	MOR+6
	stz	MOR+7

	.else

	lda	#0
	sta	MOR
	sta	MOR+1
	sta	MOR+2
	sta	MOR+3
	sta	MOR+4
	sta	MOR+5
	sta	MOR+6
	sta	MOR+7

	.endif

	;; Verifichiamo se DBR è nullo. In tal caso non entriamo nel ciclo
	lda	DBR+1
	ora	DBR+2
	ora	DBR+3
	ora	DBR+4
	beq	@storeRes
@mulcycle:
	;; Ciclo di moltiplicazione
	;; MOR = DAC*DBR

	;; Verifica se abbiamo concluso
	lda	DAC+1
	ora	DAC+2
	ora	DAC+3
	ora	DAC+4
	beq	@storeRes

	;; Ancora non abbiamo concluso!

	lsr	DAC+1		; Sposta DAC di un bit a destra
	ror	DAC+2
	ror	DAC+3
	ror	DAC+4
	bcc	@shiftMOR	; Se il primo bit era nullo, non dobbiamo addizionare DBR e la parte alta di MOR

	clc
	lda	DBR+4
	adc	MOR+3
	sta	MOR+3
	lda	DBR+3
	adc	MOR+2
	sta	MOR+2
	lda	DBR+2
	adc	MOR+1
	sta	MOR+1
	lda	DBR+1
	adc	MOR
	sta	MOR
@shiftMOR:
	ror	MOR
	ror	MOR+1
	ror	MOR+2
	ror	MOR+3
	ror	MOR+4
	ror	MOR+5
	ror	MOR+6
	ror	MOR+7

	.if	.cap(CPU_HAS_BRA8)

	bra	@mulcycle

	.else

	jmp	@mulcycle

	.endif

@storeRes:
	;; Per prima ci assicuriamo che il MSB di MOR non sia nullo
