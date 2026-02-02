; Test program for all libraries
MEMSIZE :=  8192            ; Dimensioni della memoria allocata


.export __LOADADDR__ = $0810

.segment    "HEADER"        ; Segmento contenente l'header del programma

    .word   __LOADADDR__


.zeropage

    .include "memman/memman_zp.s"
    .include "math/math_zp.s"
    .include "misc/iomisc_zp.s"

.code
    jmp START

    .include "misc/iomisc.s"
    .include "memman/memman.s"
    .include "math/math.s"

START:
    print   STARTSTR,OKSTR-STARTSTR

    ; Inizializziamo la memoria
    ldx     #<(EOF+MEMSIZE)
    ldy     #>(EOF+MEMSIZE)
    jsr     SETTOP          ; Imposta il limite superiore della memoria

    ldx     #<EOF
    ldy     #>EOF
    jsr     MEMINIT         ; Inizializza la memoria

    print   OKSTR, ALLOCSTR-OKSTR
@loop:
    allocate    VAR1NAM, VAR1NAMLEN, VAR1TYPE, VAR1BUFF, VAR1BUFFLEN
    bcs     @error
@testpoint:
    inc     VAR1NAM

    jmp     @loop
@error:
    pha
    print   ERRSTR, STARTSTR-ERRSTR
    pla
    jsr     GETERRTXT
    jsr     OUTSTR

    lda     #$0d
    jsr     PRINTCHAR

    print   ALLOCSTR, EOF-ALLOCSTR

    lda     #'v'
    sta     VAR1NAM

    lda     VAR1NAMLEN
    ldx     #<VAR1NAM
    ldy     #>VAR1NAM
    jsr     SETVARNAM

    sec
    jsr     FINDVAR
    bcs     @loop1

    print   OKSTR,ALLOCSTR-OKSTR

    jsr     REMOVEVAR
    allocate    VAR2NAM, VAR2NAMLEN, VAR2TYPE, VAR2BUFF, VAR2BUFFLEN
    bcs     @error2
    print   OKSTR, ALLOCSTR-OKSTR
@loop1:
    jmp     @loop1
@error2:
    pha
    lda     #$0d
    jsr     PRINTCHAR
    pla
    jsr     GETERRTXT
    jsr     OUTSTR
    jmp     @loop1

;Variabili
VAR1NAM:
    .byte "var1"
VAR1NAMLEN:
    .byte VAR1NAMLEN-VAR1NAM
VAR1TYPE:
    .byte $00
VAR1BUFF:
    .byte "ci metto dentro una stringa perche' e' piu' semplice"
VAR1BUFFLEN:
    .byte VAR1BUFFLEN-VAR1BUFF

VAR2NAM:
    .byte "DEF"
VAR2NAMLEN:
    .byte VAR2NAMLEN-VAR2NAM
VAR2TYPE:
    .byte $EE
VAR2BUFF:
    .byte "ora faccio un test con una stringa di due byte piu' lu"
VAR2BUFFLEN:
    .byte VAR2BUFFLEN-VAR2BUFF

;Stringhe
ERRSTR:
    .byte "si e' verificato un errore", $0d
STARTSTR:
    .byte "programma di prova.", $0d, "inizializzo la memoria... "
OKSTR:
    .byte "ok", $0d
ALLOCSTR:
    .byte "test di defrag... "
EOF:
