	;; Functions to display the content of the DAC

MAXNIBBLES:=	DACSIZE*2

DACTOHEXSTR:
	;; Converte il contenuto del DAC in una stringa esadecimale
	;; Lunghezza max della stringa = max(lmin,mantixnibbles)
	;;
	;; INPUT:	A = Lunghezza minima della stringa (max = mantixnibbles)
	;; 		X,Y = Puntatore al buffer dove lavorare
	;;
	;; OUTPUT:	A = Lunghezza effettiva della stringa

	stx	MATHPTR
	sty	MATHPTR+1
	
	cmp	#(MAXNIBBLES+1)
	bcc	@start

	lda	#MAXNIBBLES
@start:
	ldx	#0		;Numero di byte del DAC
	ldy	#0		;Numero di byte del buffer
	stx	MOR+1		;MOR+1 = Nibble corrente

	;; Calcolo il byte dal quale dobbiamo forzatamente iniziare a generare la stringa

	sta	MOR
	lda	#MAXNIBBLES
	sec
	sbc	MOR
	sta	MOR

	;; MOR: byte dal quale iniziare a generare forzatamente
	;; Ora andiamo in loop per tutti i byte del DAC
@loop:
	cpx	#DACSIZE
	bcs	@done

	;; High nibble
	lda	DAC+1,x

	lsr
	lsr
	lsr
	lsr

	jsr	@putinbuffer

	inc	MOR+1
	
	;; Low nibble
	lda	DAC+1,x
	and	#$0F
	jsr	@putinbuffer

	inc	MOR+1
	inx
	bne	@loop
@done:
	tya
	rts
@putinbuffer:
	bne	@addtobuff

	;; Il nibble è nullo
	;; Dobbiamo verificare se MOR+1 è minore di MOR
	pha
	lda	MOR+1
	cmp	MOR
	pla
	bcc	@loop

	;; Dobbiamo visualizzare uno zero

	lda	#'0'
	bne	@savetobuff
@addtobuff:
	cmp	#$10
	bcc	@common

	clc
	adc	#('a'-'9')
@common:
	clc
	adc	#('0')
@savetobuff:
	sta	(MATHPTR),y

	iny
	bne	@loop
	

HEXSTRTODAC:
	;; Converte una stringa esadecimale in un valore numerico per il DAC
	;; INPUT:	A = Lunghezza stringa
	;; 		X,Y = Puntatore alla stringa
	;; OUTPUT:	C = se settato, c'è stato un errore
	;; 		A = Codice di errore
	
	stx	MATHPTR
	sty	MATHPTR+1

	cmp	#MAXNIBBLES
	bcc	@start

	;; STRINGA TROPPO LUNGA!
	lda	#0
	rts
@start:
	tax			; X = caratteri da processare rimanenti
	ldy	#0		; Y = byte da processare

	.ifndef	MODE16

	sty	DAC+4
	sty	DAC+5
	sty	DAC+6

	.endif

	sty	DAC+1
	sty	DAC+2
	sty	DAC+3

@loop:
	dex
	bmi	@done

	.if	.cap(CPU_HAS_PUSHXY)

	phy

	.else
	
	tya
	pha

	.endif
	
	ldy	#4
@rolloop:	
	asl	DAC+1
	rol	DAC+2

	.ifndef	MODE16

	rol	DAC+3
	rol	DAC+4

	.endif

	dey
	bne	@rolloop

	;; Verifichiamo che la stringa contenga un carattere valido

	.if	.cap(CPU_HAS_PUSHXY)

	ply

	.else
	
	pla
	tay

	.endif

	lda	(MATHPTR),y	; Se è minore del carattere '0' non è sicuramente valido
	cmp	#'0'
	bcc	@inverr

	cmp	#'g'		; Se è maggiore o uguale alla lettera g non è valido
	bcs	@inverr

	;; Considerate le verifiche precedenti:
	cmp	#'a'		; Se è maggiore o uguale alla lettera a siamo a posto
	bcs	@convert

	cmp	#'9'+1		; Se è minore o uguale al numero '9' siamo a posto
	bcc	@convert
@inverr:
	;; ERRORE: è stato trovato un carattere invalido!
	sec
	lda	#1
	rts
@convert:
	sec
	sbc	#'0'

	cmp	#$10
	bcc	@putindac

	sec
	sbc	#'a'-'9'
@putindac:
	.ifndef	MODE16

	ora	DAC+4
	sta	DAC+4

	.else

	ora	DAC+2
	sta	DAC+1

	.endif

	iny
	bne	@loop
@done:
	lda	#0
	clc
	rts
