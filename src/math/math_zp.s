	;; math.s zeropage variables

	.ifdef	MODE16
DACSIZE:=2
	.else
DACSIZE:=4
	.endif

DAC:	.res	DACSIZE+1+(DACSIZE/2)
DBR:	.res	DACSIZE+1+(DACSIZE/2)
MOR:	.res	DACSIZE*2
MATHPTR:	.res	2
