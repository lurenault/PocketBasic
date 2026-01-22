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


MEMINIT:			; Inizializza il controllore della memoria
	pha

	lda #$00		; Azzera il puntatore alla prima variabile in memoria
	sta FIRSTENTRY
	sta FIRSTENTRY+1

	pla
	rts

MALLOC:
	; Alloca una determinata porzione di memoria
	rts

DEFRAG:
	; Deframmenta la memoria
	rts

FINDFREE:
	; Trova uno slot di memoria dove poter inserire la variabile
	rts

REMOVEVAR:
	; Rimuove una variabile dalla memoria
	pha 
	tya
	pha

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

	jmp	@checklast	; E' importante che non eseguiamo le istruzioni immediatamente successive, poichè a questo punto scriveremmo
				; negli indirizzi $0000-$0003!
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

	pla
	tay
	pla
	rts
