	;; Calcolo della memoria libera/usata

MMFREEMEM:
	;; INPUT: -
	;; OUTPUT: x,y=Memoria libera (low-high order)
	;; 	   Carry= set se MEMTOP è minore di MEMBOTTOM
	
	ldy	MEMTOP+1	; Se MEMTOP < MEMBOTTOM esce con il carry settato
	cpy	MEMBOTTOM+1
	bcc	@exiterr
	bne	@do

	ldx	MEMTOP
	cpx	MEMBOTTOM
	bcs	@do
@exiterr:
	sec
	rts
@do:
	pha			; Salva il contenuto del registro A

	lda	MMTEMPP1
	pha
	
	lda	MEMTOP; X contiene MEMTOP
	;; Il carry è già settato dal confronto tra MEMTOP e MEMBOTTOM
	sbc	MEMBOTTOM
	sta	MMTEMPP1
	tya			; Y contiene MEMTOP+1
	sbc	MEMBOTTOM+1
	sta	MMTEMPP1+1

	lda	FIRSTENTRY	; Imposta la variabile in esamine come la prima
	sta	CURRVAR
	lda	FIRSTENTRY+1
	sta	CURRVAR+1
@loop:
	lda	CURRVAR		; Se il puntatore alla variabile corrente è nullo, abbiamo terminato.
	ora	CURRVAR+1
	beq	@exit

	jsr	SIZEOF		; A=dimensioni della variabile in esame
	sta	MMTEMPP2

	lda	MMTEMPP1
	sec			; Sottrae le dimensioni della variabile dalla memoria disponibile
	sbc	MMTEMPP2
	sta	MMTEMPP1
	bcs	@next
	dec	MMTEMPP1+1
@next:
	ldy	#0		; Puntatore corrente = Puntatore successivo
	lda	(CURRVAR),y
	tax
	iny
	lda	(CURRVAR),y
	sta	CURRVAR+1
	stx	CURRVAR

	;; Ripete il ciclo
	.if	.cap(CPU_HAS_BRA8)

	bra	@loop

	.else

	jmp	@loop

	.endif

@exit:
	ldx	MMTEMPP1	; In output abbiamo la memoria disponibile
	ldy	MMTEMPP1+1
	pla
	sta	MMTEMPP1
	pla
	clc
	rts

	
SIZEOF:
	;; Calcola lo spazio occupato da una variabile
	;; OUTPUT:	A = Spazio occupato

	lda	#7		; Spazio minimo = 7 tra puntatori e metadata
	
	ldy	#4		; Somma ad A la dimensione dei dati della variabile
	clc
	adc	(CURRVAR),y
	
	iny			; Somma ad A la dimensione della stringa del nome della variabile
	clc
	adc	(CURRVAR),y

	rts
