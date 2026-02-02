; I/O misc library - PocketBasic - by lurenault

.ifndef IOMISCZP_H
.fatal  "Must include iomisc_zp.s in zeropage segment!"
.endif

.ifndef IOMISC_H
IOMISC_H := 1
.endif

    .out "I/O misc library by ibafegi"

    .ifdef __C64__

    PRINTCHAR :=    $FFD2

    .endif


OUTSTR:
    ; Stampa una stringa a video
    ; INPUT: A=lunghezza stringa
    ;        X,Y= Puntatore alla stringa

    stx IOMISCPTR       ;Imposta il puntatore di lettura
    sty IOMISCPTR+1

    ldy #0              ;Y=byte letto

    tax                 ;X=byte rimanenti
    bne @loop           ;Se X non è nullo, avvia la procedura
    rts
@loop:
    lda (IOMISCPTR),y   ;Preleva un byte dalla stringa
    jsr PRINTCHAR       ;Lo stampa a schermo

    iny                 ;Incrementa il contatore di lettura

    dex                 ;Decrementa i byte rimanenti
    bne @loop           ;Se X è diverso da 0 ripete il ciclo

    rts

.macro  print   buffptr, bufflen    ; Stampa una stringa
    ;UTILIZZI:
    ; print buffptr, bufflen:   Stampa una stringa che si trova all'indirizzo buffptr, la cui lunghezza è bufflen
    ; print buffptr:            Stampa una stringa che si trova all'indirizzo buffptr, la cui lunghezza è il valore del registro A

    .if (.paramcount < 1)
    .error  "Invalid call to print"
    .elseif (.paramcount > 2)
    .error  "Too many arguments for macro print"
    .endif

    .if (.paramcount = 2)
        lda #bufflen
    .endif

    ldx #<buffptr
    ldy #>buffptr
    jsr OUTSTR
.endmacro
