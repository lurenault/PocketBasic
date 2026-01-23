	;; Funzione di rimozione di una variabile
	;; by lurenault
	;;
	;; CHANGELOG:
	;; =================================================================
	;; 23/01/26:	File creato
	
REMOVEVAR:
	; Rimuove una variabile dalla memoria
	pha

	.if	.cap(CPU_HAS_PUSHXY)
		phy
	.else 
		tya
		pha
	.endif

	lda 	CURRVAR		; Se il puntatore della variabile in esamine è nullo, esce
	ora	CURRVAR+1
	beq	@exit

	ldy	#0		; Salva il puntatore alla variabile successiva in MMTEMPP1
	lda	(CURRVAR),y
	sta	MMTEMPP1
	iny
	lda	(CURRVAR),y	
	sta	MMTEMPP1+1

	iny
	lda	(CURRVAR),y	; Salva il puntatore alla variabile precedente in MMTEMPP1
	sta	MMTEMPP2
	iny
	lda	(CURRVAR),y
	sta	MMTEMPP2+1

	; Ora dobbiamo in sostanza eliminare dall'elenco la variabile corrente

	ora	MMTEMPP2
	bne	@notfirst

	; Se la variabile che stiamo eliminando è la prima, dobbiamo impostare la variabile subito dopo come la prima
	lda 	MMTEMPP1
	sta	FIRSTENTRY
	lda	MMTEMPP1+1
	sta	FIRSTENTRY+1

	.if	.cap(CPU_HAS_BRA8)
		bra	@checklast
	.else
		jmp	@checklast	; E' importante che non eseguiamo le istruzioni immediatamente successive, poichè a questo punto scriveremmo
					; negli indirizzi $0000-$0003!
	.endif

@notfirst:
	ldy	#1
	lda	MMTEMPP1+1
	sta	(MMTEMPP2),y
	dey
	lda	MMTEMPP1
	sta	(MMTEMPP2),y
@checklast:
	ora	MMTEMPP1+1	; Verifica che la variabile in esamine non sia l'ultima. In tal caso esce dalla routine
	beq	@exit

	; Imposta i puntatori della variabile precedente
	ldy	#2
	lda	MMTEMPP2
	sta	(MMTEMPP1),y
	iny
	lda	MMTEMPP2+1
	sta	(MMTEMPP1),y
@exit:
	lda	FIRSTENTRY	; Imposta la variabile corrente alla prima in memoria. Questo per evitare problemi lasciando "attiva" una variabile
	sta	CURRVAR		; che non c'è più!
	lda	FIRSTENTRY+1
	sta	CURRVAR+1

	.if	.cap(CPU_HAS_PUSHXY)
		ply
	.else
		pla
		tay
	.endif
	pla
	rts
