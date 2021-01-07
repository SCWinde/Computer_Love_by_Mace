.pc = $d000 "VIC registry" virtual
.namespace VIC {
	.namespace sprite1 {		// $d000, $d001

		X:		.byte $00
		Y:		.byte $00
		.label color = * +$25	// $d027
		}
	.namespace sprite2 {		// $d002, $d003
		X:	.byte $00
		Y:	.byte $00
		.label color = * +$24	// $d028
		}
	.namespace sprite3 {		// $d004, $d005
		X:	.byte $00
		Y:	.byte $00
		.label color = * +$23	// $d029
		}
	.namespace sprite4 {		// $d006, $d007
		X:	.byte $00
		Y:	.byte $00
		.label color = * +$22	// $d02a
		}
	.namespace sprite5 {		// $d008, $d009
		X:	.byte $00
		Y:	.byte $00
		.label color = * +$21	// $d02b
		}
	.namespace sprite6 {		// $d00a, $d00b
		X:	.byte $00
		Y:	.byte $00
		.label color = * +$20	// $d02c
		}
	.namespace sprite7 {		// $d00c, $d00d
		X:	.byte $00
		Y:	.byte $00
		.label color = * +$1f	// $d02d
		}
	.namespace sprite8 {		// $d00e, $d00f
		X:	.byte $00
		Y:	.byte $00
		.label color = * +$1e	// $d02e
		}

	spriteMSB:		.byte $00	// $d010
	ctrlReg1:		.byte $00	// $d011
	rasterLine:		.byte $00	// $d012

	.namespace lightPen {		// $d013, $d014
		X:	.byte $00
		Y:	.byte $00
		}
	
	spriteEnable:	.byte $00	// $d015
	ctrlReg2:		.byte $00	// $d016
	spriteExpandY:	.byte $00	// $d017
	screenPointer:	.byte $00	// $d018
	irqFlag:		.byte $00	// $d019
	irqMaskL:		.byte $00	// $d01a
	spritePrio:		.byte $00	// $d01b
	spriteColorMode:.byte $00	// $d01c
	spriteExpandX:	.byte $00	// $d01d
	spriteCollision:.byte $00	// $d01e
	fgCollision:	.byte $00	// $d01f

	.namespace color {			// $d020 .. #d026
		border:		.byte $00	// $d020
		screen:		.byte $00	// $d021

		background1:.byte $00	// $d022
		background2:.byte $00	// $d023
		background3:.byte $00	// $d024

		spriteMC1:	.byte $00	// $d025
		spriteMC2:	.byte $00	// $d026
		}
}