	;; Trova uno spazio libero in memoria


FINDFREESPOT:
	;; Input: A=Dimensioni
	;; OUTPUT: C= se settato, non c'è uno spazio sufficientemente grande

	sta	MMTEMPP1+1
	;; Per prima cosa verifichiamo se c'è uno spazio tra due variabili sufficientemente grande
	lda	FIRSTENTRY
	sta	CURRVAR
	lda	FIRSTENTRY+1
	sta	CURRVAR+1
@findintrspa:
	;; Se (CURRVAR) è nullo, abbiamo terminato il ciclo senza trovare nulla
	lda	CURRVAR
	ora	CURRVAR+1
	beq	@checkbottom

	;; Copia (CURRVAR) in (MMTEMPP2)
	lda	CURRVAR
	sta	MMTEMPP2
	lda	CURRVAR+1
	sta	MMTEMPP2+1

	;; Calcola la dimensione della variabile corrente
	jsr	SIZEOF

	;; (CURRVAR) = (CURRVAR) + SIZEOF(CURRVAR), ovvero in (CURRVAR) mettiamo l'indirizzo di fine della variabile + 1
	clc
	adc	CURRVAR
	sta	CURRVAR
	pha			; Mette il low byte di CURRVAR nello stack
	lda	#0
	tay			; Y = 0, utile per le prossime operazioni
	adc	CURRVAR+1
	sta	CURRVAR+1

	;; Ora calcoliamo lo spazio inutilizzato tra le due variabili
	;; Se la variabile in esamine è l'ultima, dobbiamo verificare la distanza da MEMTOP!
	lda	(MMTEMPP2),y
	iny
	ora	(MMTEMPP2),y
	bne	@notlast

	;; ULTIMA VARIABILE
	lda	MEMTOP
	sec
	sbc	CURRVAR
	sta	CURRVAR
	lda	MEMTOP+1
	sbc	CURRVAR+1

	;; Poi continua con il ciclo
	.if	.cap(CPU_HAS_BRA8)

	bra	@checkintsuff

	.else

	jmp	@checkintsuff

	.endif
@notlast:
	lda	(MMTEMPP2),y	; La memoria tra gli spazi è uguale a INDIRIZZO INIZIO VARIABILE SUCCESSIVA -
	sec			; - INDIRIZZO FINE VARIABILE CORRENTE+1
	sbc	CURRVAR
	sta	CURRVAR
	iny
	lda	(MMTEMPP2),y
	sbc	CURRVAR+1
@checkintsuff:
	;; Ora verifichiamo se questa memoria è sufficiente
	bne	@foundint	; Se l'high byte della memoria tra gli spazi non è nullo, l'abbiamo sicuramente trovato

	lda	CURRVAR		; Verifica se c'è spazio a sufficienza
	cmp	MMTEMPP1+1
	bcc	@nextint
@foundint:
	;; C'è spazio disponibile
	pla			; Rimette il low byte di CURRVAR ( che sarà il puntatore all'indirizzo della nuova variabile )
	sta	CURRVAR
	;; MMTEMPP2 = Puntatore variabile precedente
	ldy	#0		; MMTEMPP1 = Puntatore variabile successiva
	lda	(MMTEMPP2),y
	sta	MMTEMPP1
	iny
	lda	(MMTEMPP2),y
	sta	MMTEMPP1+1

	clc
	rts
@nextint:
	pla			; Il low byte di CURRVAR non ci serve più
	ldy	#0
	lda	(MMTEMPP2),y	; Passa ad esaminare la variabile successiva
	sta	CURRVAR
	iny
	lda	(MMTEMPP2),y
	sta	CURRVAR+1

	.if	.cap(CPU_HAS_BRA8)

	bra	@findintrspa

	.else

	jmp	@findintrspa

	.endif
@checkbottom:
	;; Non abbiamo trovato niente col metodo precedente, non ci resta che vedere se c'è dello spazio tra FIRSTENTRY e MEMBOTTOM

	lda	FIRSTENTRY
	sec
	sbc	MEMBOTTOM
	tax
	lda	FIRSTENTRY+1
	sbc	MEMBOTTOM+1
	bne	@foundbottom

	cpx	MMTEMPP1+1
	bcs	@foundbottom

	sec
	rts
@foundbottom:
	;; CURRVAR = FIRSTENTRY - SIZEOF(VARIABILE DA AGGIUNGERE)
	;; MMTEMPP1 = FIRSTENTRY
	lda	FIRSTENTRY
	sta	MMTEMPP1
	sec
	sbc	MMTEMPP1+1
	sta	CURRVAR

	lda	FIRSTENTRY+1
	sta	MMTEMPP1+1
	sbc	#0
	sta	CURRVAR

	;; MMTEMPP2 = 0
	.if	.cap(CPU_HAS_STZ)

	stz	MMTEMPP2
	stz	MMTEMPP2+1

	.else

	lda	#0
	sta	MMTEMPP2
	sta	MMTEMPP2+1

	.endif

	clc
	rts
