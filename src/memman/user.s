	;; ROUTINE per l'utilizzo effettivo del gestore di memoria

FINDVAR:
	;; Trova una variabile, dati nome e tipo
	;; SETUP: SETVARNAM
	;; 	  SETVARTYP
	;; INPUT: C = se settato cerca solo in base al nome
	;; OUTPUT: C = se settato la variabile non è stata trovata

	lda	#$FF
	bcc	@start
	lda	#0
@start:
	;; A=switch ricerca con tipo
	;; salva A in MMTEMPP1
	sta	MMTEMPP1
	
	;; Imposta il puntatore alla variabile corrente con la prima variabile
	lda	FIRSTENTRY
	sta	CURRVAR
	lda	FIRSTENTRY+1
	sta	CURRVAR+1
@loop:
	;; Verifica se abbiamo controllato tutte le variabili
	lda	CURRVAR
	ora	CURRVAR+1
	bne	@continue

	;; Abbiamo letto tutte le variabili senza trovare riscontro !!
	sec
	rts
@continue:
	;; Controlla se abbiamo una corrispondenza di lunghezza del nome
	ldy	#5
	lda	(CURRVAR),y
	cmp	MMNAMELEN
	bne	@nextvar

	;; Abbiamo corrispondenza di nome, quindi controlliamo se dobbiamo guardare il tipo
	lda	MMTEMPP1	; Se MMTEMPP1 è nullo, non dobbiamo controllare il tipo
	beq	@checkname

	;; Controlliamo il tipo
	ldy	#6
	lda	(CURRVAR),y
	cmp	MMVARTYPE
	bne	@nextvar
@checkname:
	;; Abbiamo anche la corrispondenza di tipo, non ci resta che controllare se i nomi coincidono
	;; Prepariamo il loop

	lda	#7
	sta	MMTEMPP2

	ldx	MMNAMELEN

	.if	.cap(CPU_HAS_STZ)

	stz	MMTEMPP2+1

	.else

	lda	#0
	sta	MMTEMPP2+1

	.endif

@nameloop:
	ldy	MMTEMPP2
	lda	(CURRVAR),y
	ldy	MMTEMPP2+1
	cmp	(MMNAMEPTR),y
	bne	@nextvar	;Se anche un singolo carattere non coincide, i nomi non coincidono

	inc MMTEMPP2
	inc MMTEMPP2+1
	dex
	bne	@nameloop

	;; Se ci troviamo qui, abbiamo trovato la variabile!

	clc
	rts
@nextvar:
	ldy	#0
	lda	(CURRVAR),y
	tax
	iny
	lda	(CURRVAR),y
	sta	CURRVAR+1
	stx	CURRVAR

	.if	.cap(CPU_HAS_BRA8)

	bra	@loop

	.else

	jmp	@loop

	.endif

SETVARNAM:
	;; Imposta il nome della variabile da aggiungere/cercare/rimuovere
	;; Input: A = Lunghezza nome
	;; 	  X,Y = Indirizzo della stringa

	sta	MMNAMELEN
	stx	MMNAMEPTR
	sty	MMNAMEPTR+1

	rts

SETVARTYP:
	;; Imposta il tipo di variabile
	;; Input: A = Tipo di variabile

	sta	MMVARTYPE
	rts

SETVARBUFF:
	;; Imposta il buffer da cui prendere i dati da mettere alla variabile
	;; INPUT: A = lunghezza buffer
	;;        X,Y = Indirizzo del buffer

	sta	MMBUFFLEN
	stx	MMBUFFPTR
	sty	MMBUFFPTR+1

	rts
	
GETBUFFPTR:
	;; Restituisce l'indirizzo dove sono presenti i dati della variabile
	;; SETUP: SETVARNAM o SETVARNAM+SETVARTYP e FINDVAR
	;; OUTPUT: A = lunghezza buffer
	;; 	   X,Y = Posizione dei dati in memoria

	;; (XY) = (CURRVAR) + 7 + Lunghezza nome
	lda	#7
	ldy	#5
	clc
	adc	(CURRVAR),y

	clc
	adc	CURRVAR
	sta	MMTEMPP1

	lda	CURRVAR
	adc	#0
	sta	MMTEMPP1+1

	ldy	#4
	lda	(CURRVAR),y

	ldx	MMTEMPP1
	ldy	MMTEMPP1+1

	rts
