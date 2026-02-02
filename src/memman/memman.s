; Memory manager by lurenault
;


; Struttura di una variabile salvata in memoria
;
; $00-$01	Puntatore alla variabile successiva ( $0000 se è l'ultima )
; $02-$03	Puntatore alla variabile precedente ( $0000 se è la prima )
; $04		Dimensioni del contenuto della variabile
; $05		Lunghezza del nome della variabile ( max 16 caratteri )
; $06		Tipo di variabile (irrilevante per il manager di memoria, usato solo dal basic)
; $07-$xx	Nome variabile
; $xx-$yy	Contenuto della variabile


	;; Procedura di inizializzazione (COLD START)
	;; 1) chiamare SETTOP
	;; 2) chiamare MEMINIT
	;;
	;; WARM START ( ad esempio quando l'utente digita RUN dal prompt basic )
	;; - chiamare MEMINIT
	
	.ifndef	MEMMANZP_H
	.fatal	"Must include memman_zp.s in zeropage section!"
	.else

	.out	"Memory Manager v0.1 by lurenault"

SETTOP:
	;; Imposta il limite superiore della memoria utilizzabile
	;; Input: x,y= Ultimo indirizzo utilizzabile+1 (low-high order)

	stx	MEMTOP
	sty	MEMTOP+1
	rts

	
MEMINIT:
	;; Inizializza il controllore della memoria
	;; INPUT: x,y= Indirizzo di inizio memoria utile

	;; Azzera il puntatore alla prima variabile in memoria e alla variabile corrente
	.if	.cap(CPU_HAS_STZ)
	
	stz	FIRSTENTRY
	stz	FIRSTENTRY+1
	stz	CURRVAR
	stz	CURRVAR+1
	
	.else
	
	lda 	#$00
	sta 	FIRSTENTRY
	sta 	FIRSTENTRY+1
	sta	CURRVAR
	sta	CURRVAR+1
	
	.endif
	;; Imposta l'inizio della memoria
	;; Salva l'indirizzo di inizio memoria utile
	stx	MEMBOTTOM
	sty	MEMBOTTOM+1

	; Ora calcoliamo la memoria disponibile
	lda	MEMTOP
	sec
	sbc MEMBOTTOM
	sta	MMFREE

	lda	MEMTOP+1
	sbc	MEMBOTTOM+1
	sta	MMFREE+1

	; Se il carry è settato, MEMTOP < MEMBOTTOM!
	rts

MOVEBOTTOM:
	;; Sposta l'inizio della memoria allocata (se possibile)
	;; INPUT: x,y = Indirizzo al quale spostare l'inizio della memoria
	;; OUTPUT: Carry = se settato, non c'è spazio disponibile per spostare la memoria
	pha

	lda	MEMBOTTOM	;Salva l'inizio della memoria attuale nello stack
	pha
	lda	MEMBOTTOM+1
	pha

	stx	MEMBOTTOM	;Prova ad impostare l'inizio della memoria
	sty	MEMBOTTOM+1

	lda	FIRSTENTRY+1	;Se la prima variabile in memoria ha un indirizzo 
	cmp	MEMBOTTOM+1	;inferiore al nuovo inizio della memoria, proviamo a vedere
	bcs	@done		;se deframmentando ci stia

	lda	FIRSTENTRY
	cmp	MEMBOTTOM
	bcs	@done

	;; Forse non c'è spazio disponibile, proviamo a deframmentare la memoria
	ldx	#$FF		;Forza deframmentazione totale, con aggiornamento link alla
	ldy	#$FF		;prima entrata di memoria
	jsr	DEFRAG

	lda	FIRSTENTRY+1	;Ripete lo stesso controllo fatto prima, ma se questa volta
	cmp	MEMBOTTOM+1	;fallisce...
	bcs	@done

	lda	FIRSTENTRY
	cmp	MEMBOTTOM
	bcs	@done

	;; NON C'E' MEMORIA SUFFICIENTE
	;; Ripristina il vecchio inizio di memoria
	pla
	sta	MEMBOTTOM+1
	pla
	sta	MEMBOTTOM

	;; Riprende A dallo stack ed esce col carry settato
	pla
	sec
	rts
@done:
	;; Scarta il vecchio inizio di memoria
	pla
	pla
	;; Riprende A dallo stack ed esce col carry nullo
	pla
	clc
	rts
	
	.include	"alloc.s"
	.include	"defrag.s"
	.include	"freemem.s"
	.include	"remove.s"
	.include	"findspot.s"
	.include	"user.s"

	.endif
