
.byte $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $2f, $2f, $8f, $8f, $7f // 1
.byte $7f, $5f, $5f, $6f, $6f, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf
.byte $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $2f, $2f, $8f, $8f, $7f // 2
.byte $7f, $5f, $5f, $6f, $6f, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf
.byte $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $2f, $2f, $8f, $8f, $7f // 3
.byte $7f, $5f, $5f, $6f, $6f, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf
.byte $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $2f, $2f, $8f, $8f, $7f // 4
.byte $7f, $5f, $5f, $6f, $6f, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf
.byte $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $2f, $2f, $8f, $8f, $7f // 5
.byte $7f, $5f, $5f, $6f, $6f, $cf, $1f, $1f, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf

.fill $28, $1f // 6
.fill $28, $1f // 7
.fill $28, $1f // 8

.byte $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $2f, $2f, $8f, $8f, $7f // 9
.byte $7f, $5f, $5f, $6f, $6f, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf
.byte $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $2f, $2f, $8f, $8f, $7f // 10
.byte $7f, $5f, $5f, $6f, $6f, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf
.byte $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $2f, $2f, $8f, $8f, $7f // 11
.byte $7f, $5f, $5f, $6f, $6f, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf
.byte $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $2f, $2f, $8f, $8f, $7f // 12
.byte $7f, $5f, $5f, $6f, $6f, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf, $cf

.fill $28, $ff // 13
.fill $28, $ff // 14
.fill $28, $ff // 15

.for (var y=0; y<6; y++) {
	.for (var x=0; x<39; x++)
		.byte x*6+y+2
	.byte $ff
	}

.fill $28, $ff // 22
.fill $28, $ff // 23

.byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $22, $ff, $88, $ff, $77 // 24
.byte $ff, $55, $ff, $66, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
.byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $22, $ff, $88, $ff, $77 // 25
.byte $ff, $55, $ff, $66, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff