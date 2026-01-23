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
.error	"Must include memman_zp.s in zeropage section!"
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
	
	pha
	
	lda 	#$00
	sta 	FIRSTENTRY
	sta 	FIRSTENTRY+1
	sta	CURRVAR
	sta	CURRVAR+1

	pla
	
	.endif
SETBOTTOM:
	;; Imposta l'inizio della memoria
	;; Salva l'indirizzo di inizio memoria utile
	stx	MEMBOTTOM
	sty	MEMBOTTOM+1

	rts

.include	"alloc.s"

DEFRAG:
	; Deframmenta la memoria
	rts

FINDFREE:
	; Trova uno slot di memoria dove poter inserire la variabile
	rts
	
.include	"freemem.s"
.include	"remove.s"
.include	"findspot.s"	

.endif
