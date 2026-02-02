	;; Routine di addizione/sottrazione

IADD  :
	;; Addizione tra interi a 32 bit immediata (usa il registro DBR)

	jsr	FIXEXP		; Ci assicuriamo che entrambi i registri abbiano
				; lo stesso esponente

	clc
	
	.ifndef	MODE16

	lda	DAC+4		; Esegue DAC = DAC+DBR
	adc	DBR+4
	sta	DAC+4
	lda	DAC+3
	adc	DBR+3
	sta	DAC+3

	.endif
	
	lda	DAC+2
	adc	DBR+2
	sta	DAC+2
	lda	DAC+1
	adc	DBR+1
	sta	DAC+1

	rts

ISUB:
	;; Sottrazione tra interi a 32 bit

	jsr	FIXEXP		; Ci assicuriamo che i registri abbiano lo stesso esponente

	sec

	.ifndef	MODE16

	lda	DAC+4
	sbc	DBR+4
	sta	DAC+4
	lda	DAC+3
	sbc	DBR+3
	sta	DAC+3

	.endif

	lda	DAC+2
	sbc	DBR+2
	sta	DAC+2
	lda	DAC+1
	sbc	DBR+1
	sta	DAC+1

	rts
