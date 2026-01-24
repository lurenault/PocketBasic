	;; Allocazione della memoria

	;; CODICI DI ERRORE FUNZIONE MALLOC
	MMINVSIZE	:=	$01 ; La variabile ha grandezza superiore a 256 byte
	MMSTRSIZE	:=	$02 ; La stringa del nome occupa più di 16 byte
	MMNOSPACE	:=	$03 ; La memoria disponibile non è sufficiente
	MMINVINIT	:=	$04 ; La memoria non è inizializzata correttamente: MEMTOP è minore di MEMBOTTOM
	MMNAMEXIS	:=	$05 ; Esiste già una variabile con questo nome

MALLOC:
	;; Alloca una variabile in memoria
	;; OUTPUT:	A=codice di errore ($00 se ok)
	;; 		Carry= set se c'è un errore
	;; 
	;; DATI DELLA VARIABILE:
	;; 	MMNAMEPTR	:	Puntatore alla stringa del nome della variabile da aggiungere
	;; 	MMNAMELEN	:	Lunghezza della stringa del nome della variabile da aggiungere
	;; 	MMVARTYPE	:	Tipo di variabile
	;; 	MMBUFFPTR	:	Puntatore al buffer contenente il valore della variabile
	;; 	MMBUFFLEN	:	Lunghezza del buffer

	;; Come prima cosa, verifichiamo che il nome sia al massimo 16 caratteri
	lda	MMNAMELEN
	beq	@nameerr	; Se il nome ha lunghezza nulla, dà errore

	cmp	#16
	bcc	@checkexists	; Se il nome è più piccolo o uguale di 16 caratteri siamo a posto.

@nameerr:
	;; ERRORE: nome troppo lungo
	sec
	lda	#MMSTRSIZE
	rts
@checkexists:
	;; Ora controlliamo se esiste già una variabile con questo nome
	sec			; Chiamata a FINDVAR con carry settato: non guarda al tipo
	jsr	FINDVAR
	bcs	@checksize

	;; FINDVAR HA TROVATO UNA VARIABILE CON LO STESSO NOME
	sec
	lda	#MMNAMEXIS
	rts
@checksize:
	;; Ora controlliamo la lunghezza complessiva della variabile
	lda	#7		; 7= dimensione minima variabile
	clc
	adc	MMNAMELEN

	;; Il carry è sicuramente nullo in quanto 7 + al massimo 16 è sicuramente minore di 256
	adc	MMBUFFLEN
	bcc	@checkfreespace	; Se il carry è nullo siamo a posto.

	;; ERRORE: variabile troppo grande
	;; Nota: il carry è già settato dalla precedente operazione
	lda	#MMINVSIZE
	rts
@checkfreespace:
	;; Ora calcoliamo lo spazio disponibile e verifichiamo che la variabile ci stia dentro
	sta	MMTEMPP1	; Salva lo spazio occupato dalla variabile
	jsr 	MMFREE		; Calcola la memoria disponibile
	bcc	@findspot	; Se il carry è nullo siamo a posto

	;; ERRORE: MEMTOP < MEMBOTTOM
	lda	#MMINVINIT
	rts
@findspot:
	;; Ora dobbiamo cercare uno spazio in memoria dove poter mettere la variabile
	lda	MMTEMPP1	; A = spazio occupato dalla variabile
	jsr	FINDFREESPOT
	bcc	@setvar

	;; Se non è stato trovato alcuno spazio, deframmenta la memoria quanto basta per avere A bytes di spazio
	ldx	MMTEMPP1	; A = spazio occupato dalla variabile
	ldy	#0
	jsr	DEFRAG
@setvar:
	;; A questo punto abbiamo i seguenti valori in memoria:
	;;  CURRVAR = Indirizzo di memoria libero trovato
	;;  MMTEMPP2 = Indirizzo della variabile precedente
	;;  MMTEMPP1 = Indirizzo della variabile successiva

	;; Dobbiamo linkare la nostra variabile

	;; Aggiunta del link alla variabile precedente solo se non diventa la prima
	lda	MMTEMPP2
	ora	MMTEMPP2+1
	beq	@linksucc
	
	ldy	#0
	lda	CURRVAR
	sta	(MMTEMPP2),y
	iny
	lda	CURRVAR+1
	sta	(MMTEMPP2),y
@linksucc:
	;; Aggiunta del link alla variabile successiva, solo se la nostra non sarà l'ultima
	lda	MMTEMPP1
	ora	MMTEMPP1+1
	beq	@checklinkfirst

	ldy	#2
	lda	CURRVAR
	sta	(MMTEMPP1),y
	iny
	lda	CURRVAR+1
	sta	(MMTEMPP1),y
@checklinkfirst:
	;; Se la variabile sarà la prima, aggiorna il puntatore alla prima variabile
	lda	MMTEMPP2
	ora	MMTEMPP2+1
	bne	@startcopy

	lda	CURRVAR		
	sta	FIRSTENTRY
	lda	CURRVAR+1
	sta	FIRSTENTRY+1
@startcopy:
	;; Ora linkiamo le altre variabili alla nostra
	ldy	#0
	lda	MMTEMPP1
	sta	(CURRVAR),y
	iny
	lda	MMTEMPP1+1
	sta	(CURRVAR),y

	iny
	lda	MMTEMPP2
	sta	(CURRVAR),y
	iny
	lda	MMTEMPP2+1
	sta	(CURRVAR),y
	
	;; Copiamo i metadata
	iny
	lda	MMBUFFLEN
	sta	(CURRVAR),y
	iny
	lda	MMNAMELEN
	tax			; Ci servirà più avanti
	sta	(CURRVAR),y
	iny
	lda	MMVARTYPE
	sta	(CURRVAR),y

	;; Copiamo il nome con un semplice loop

	;; Azzera MMTEMPP2+1 ( contatore di lettura )
	.if	.cap(CPU_HAS_STZ)

	stz	MMTEMPP2+1

	.else

	lda	#0
	sta	MMTEMPP2+1

	.endif

	;; Aggiorna MMTEMPP 2 ( contatore di scrittura )
	iny
	sty	MMTEMPP2
@nameloop:
	ldy	MMTEMPP2+1	
	lda	(MMNAMEPTR),y	; Carica dalla stringa
	ldy	MMTEMPP2
	sta	(CURRVAR),y	; Salva nella variabile

	inc	MMTEMPP2	; Incrementa i contatori di offset
	inc	MMTEMPP2+1

	dex			; Decrementa X ( dimensione della stringa )
	bne	@nameloop	; Se X != 0, ripete il ciclo

	;; Ora dobbiamo solo copiare i dati contenuti nella variabile

	ldx	MMBUFFLEN	; X = Lunghezza buffer

	;; Azzera il contatore di lettura
	.if	.cap(CPU_HAS_STZ)

	stz	MMTEMPP2+1

	.else

	lda	#0
	sta	MMTEMPP2+1

	.endif
@buffloop:
	ldy	MMTEMPP2+1	; Preleva dal buffer
	lda	(MMBUFFPTR),y
	ldy	MMTEMPP2	; Salva nella variabile
	sta	(CURRVAR),y

	inc	MMTEMPP2	; Incrementa i contatori
	inc	MMTEMPP2+1

	dex			; Decrementa il numero di byte rimanenti
	bne	@buffloop	; Se non è nullo, ripete il ciclo

	;; Abbiamo terminato
	lda	#0		; Codice di errore nullo
	clc			; 
	rts
