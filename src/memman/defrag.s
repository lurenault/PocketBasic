	;; Deframmenta la memoria

DEFRAG:
	;; INPUT: x,y = Spazio minimo necessario
	;; OUTPUT: CURRVAR = Puntatore alla prima zona di memoria utile trovata
	;;         MMTEMPP1 = Puntatore alla variabile successiva
	;;         MMTEMPP2 = Puntatore alla variabile precedente

	;; MMTEMPP1 = Memoria necessaria
	stx	MMTEMPP2
	sty	MMTEMPP2+1

	;; Ora dobbiamo trovare l'ultima variabile disponibile

	;; Si parte dalla prima variabile in memoria
	lda	FIRSTENTRY
	sta	CURRVAR
	lda	FIRSTENTRY+1
	sta	CURRVAR+1

	ldx	#0		; Velocizza un po' l'operazione
@findlast:
	ldy	#1		; E' l'ultima solo se il puntatore alla variabile successiva è nullo
	lda	(CURRVAR),y
	ora	(CURRVAR,x)
	beq	@foundlast

	;; Non è l'ultima, quindi (CURRVAR) = Puntatore locazione successiva
	lda	(CURRVAR),y
	tay
	lda	(CURRVAR,x)
	sta	CURRVAR
	sty	CURRVAR+1

	.if	.cap(CPU_HAS_BRA8)

	bra	@findlast

	.else

	jmp	@findlast

	.endif
@foundlast:
	;; Ora che ci troviamo all'ultima variabile, impostiamo il ciclo di deframmentazione

	;; MMTEMPP1 = Indirizzo variabile successiva
	;; Visto che siamo all'ultima, lo impostiamo al valore di MEMTOP per semplificare
	lda	MEMTOP
	sta	MMTEMPP1
	lda	MEMTOP+1
	sta	MMTEMPP1+1

@defloop:
	;; Verifichiamo se la zona è frammentata

	;; X,Y = Indirizzo di fine variabile + 1
	jsr	SIZEOF
	clc
	adc	CURRVAR
	tax
	lda	#0
	adc	CURRVAR+1
	tay

	;; Se X,Y == Puntatore locazione successiva, la zona di memoria non è frammentata 
	cpx	MMTEMPP1
	bne	@fragm

	cpy	MMTEMPP1+1
	bne	@fragm

	jmp	@next
@fragm:
	;; LOCAZIONE FRAMMENTATA
	;; Verifichiamo se ha una grandezza sufficiente
	;; X,Y = Grandezza spazio = (MMTEMPP1)-(XY)


	lda	MMTEMPP1
	pha			; Salva il low byte della locazione successiva nello stack
	stx	MMTEMPP1
	sec
	sbc	MMTEMPP1
	tax

	lda	MMTEMPP1+1
	pha			; Salva l'high byte della locazione successiva nello stack
	sty	MMTEMPP1+1
	sbc	MMTEMPP1+1
	tay
	;; Dopo ciò MMTEMPP1 = Indirizzo fine variabile + 1
	
	cpy	MMTEMPP2+1	; Se l'high byte della grandezza dello spazio è minore
	bcc	@defrag		; dell'high byte della grandezza richiesta, non abbiamo trovato nulla
	bne	@found		; Se sono uguali dobbiamo verificare il low byte

	cpx	MMTEMPP2
	bcc	@defrag		; Se anche il low byte è minore, non abbiamo trovato nulla e dobbiamo deframmentare
@found:
	;; MMTEMPP2 = Indirizzo variabile corrente ( che diventerà la precedente )
	;; MMTEMPP1 = Indirizzo variabile successiva
	;; CURRVAR = Indirizzo locazione trovata ( valore corrente di MMTEMPP1 )

	ldx	MMTEMPP1	; XY = Lacazione di memoria trovata
	ldy	MMTEMPP1+1

	lda	CURRVAR
	sta	MMTEMPP2
	lda	CURRVAR+1
	sta	MMTEMPP2+1

	stx	CURRVAR
	sty	CURRVAR+1
	
	;; Impostiamo il puntatore alla variabile successiva
	ldy	#0
	lda	(MMTEMPP2),y
	sta	MMTEMPP1
	iny
	lda	(MMTEMPP2),y
	sta	MMTEMPP1+1

	pla			; Ripristina lo stack
	pla
	;; Abbiamo terminato!
	rts
@defrag:
	;; E' necessario deframmentare la memoria
	;; Calcoliamo l'indirizzo dove andare a copiare la variabile corrente
	;; MMTEMPP1 = Indirizzo di copia = (Locazione successiva (STACK))-SIZEOF(CURRVAR)

	jsr	SIZEOF
	tay
	pla
	sta	MMTEMPP1+1
	pla
	sty	MMTEMPP1
	sec
	sbc	MMTEMPP1
	sta	MMTEMPP1

	lda	MMTEMPP1+1
	sbc #0
	sta	MMTEMPP1+1

	;; Situazione corrente:
	;; Y = SIZEOF(CURRVAR)
	;; (MMTEMPP1) = Indirizzo di copia

	;; Loop di copia della variabile
@copyloop:
	dey
	bmi	@copydone

	lda	(CURRVAR),y	;Copia dall'indirizzo vecchio all'indirizzo nuovo
	sta	(MMTEMPP1),y

	.if	.cap(CPU_HAS_BRA8)

	bra	@copyloop

	.else

	jmp	@copyloop

	.endif
@copydone:
	;; Ora dobbiamo linkare correttamente la variabile spostata
	lda	MMTEMPP1	; Aggiorna l'indirizzo della variabile appena deframmentata
	sta	CURRVAR
	lda	MMTEMPP1+1
	sta	CURRVAR+1
	
	ldy	#1
	ldx	#0
	lda	(CURRVAR),y	; Se è l'ultima, non dobbiamo linkare nulla
	ora	(CURRVAR,x)
	beq	@linkprev

	;; NON E' L'ULTIMA
	;; Preleva l'indirizzo della variabile successiva
	lda	(CURRVAR),y
	sta	MMTEMPP1+1
	lda	(CURRVAR,x)
	sta	MMTEMPP1

	;; Linka la variabile corrente a quella successiva
	ldy	#2
	lda	CURRVAR
	sta	(MMTEMPP1),y
	iny
	lda	CURRVAR+1
	sta	(MMTEMPP1),y
@linkprev:
	ldy	#2		; Se è la prima, non dobbiamo linkare alla prima variabile
	lda	(CURRVAR),y
	iny
	ora	(CURRVAR),y
	beq	@next

	;; NON E' LA PRIMA
	;; Preleva l'indirizzo della variabile precedente
	ldy	#2
	lda	(CURRVAR),y
	sta	MMTEMPP1
	iny
	lda	(CURRVAR),y
	sta	MMTEMPP1+1

	;; Aggiorna il link
	ldy	#0
	lda	CURRVAR
	sta	(MMTEMPP1),y
	iny
	lda	CURRVAR+1
	sta	(MMTEMPP1),y
@next:
	;; CURRVAR = Variabile precedente
	lda	CURRVAR
	sta	MMTEMPP1
	lda	CURRVAR+1
	sta	MMTEMPP1+1

	ldy	#2		; Se era la prima variabile, significa che lo spazio è disponibile tra lei e la prima variabile
	lda	(MMTEMPP1),y
	iny
	ora	(MMTEMPP1),y
	beq	@findinbottom

	dey
	lda	(MMTEMPP1),y
	sta	CURRVAR
	iny
	lda	(MMTEMPP1),y
	sta	CURRVAR+1

	;; A questo punto ripetiamo il ciclo!
	jmp 	@defloop
@findinbottom:
	;; Se SIZEOF(Variabile da aggiungere) == $FFFF, FIRSTENTRY = MMTEMPP1
	lda	MMTEMPP2
	and	MMTEMPP2+1
	cmp	#$FF
	bne	@notfulldef

	lda	MMTEMPP1
	sta	FIRSTENTRY
	lda	MMTEMPP1+1
	sta	FIRSTENTRY+1

	.if	.cap(CPU_HAS_BRA8)

	bra	@quit

	.else

	jmp	@quit

	.endif
@notfulldef:
	;; (CURRVAR)=(MMTEMPP1)-(Spazio richiesto, ovvero MMTEMPP2)
	;; (MMTEMPP2) = 0

	lda	MMTEMPP1
	sec
	sbc	MMTEMPP2
	sta	CURRVAR
	lda	MMTEMPP1+1
	sbc	MMTEMPP2+1
	sta	CURRVAR+1

	.if	.cap(CPU_HAS_STZ)

	stz	MMTEMPP2
	stz	MMTEMPP2+1

	.else

	lda	#0
	sta	MMTEMPP2
	sta	MMTEMPP2+1

	.endif
@quit:
	rts
