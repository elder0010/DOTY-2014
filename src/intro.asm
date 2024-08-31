intro_music_irq:
		:open_irq()

		asl $d019

	.if(debug_music){inc $d020}
	//	jsr music.play
	.if(debug_music){dec $d020}

		inc inct+1
inct:
		lda #0
initial_delay:
		cmp #$65

		bne !+

i_irq_lo:
		lda #<bottom_border_irq
		sta $fffe
i_irq_hi:
		lda #>bottom_border_irq
		sta $ffff
!:
		:close_irq()
		rti

.align $100
//INTRO WOB WOB on borders
border_stabilizer_irq:
		sta reset_a
		stx reset_x
		sty reset_y

		lda #<border_stabilized_irq
		sta $fffe

		inc $d012

		asl $d019
		tsx

		cli

		.for(var n=0;n<16;n++){
			nop
		}

		brk

border_stabilized_irq:
		txs
		ldx #$8
!:		dex
		bne !-

		bit $24
		nop

		lda #border_stabilizer_irq_line+1
		cmp $d012
		beq !+
!:

		ldy #10
		:wait()

		bit $24

		lda #RED
		sta $d020

.if(debug_music){inc $d020}
top_ply:
		bit music.play
.if(debug_music){dec $d020}

hibyte_top:
		lda #$1b
!:
		cmp $d011
		bne !-

		ldx #LIGHT_BLUE
ll:
		lda #$6
!:
		cmp $d012
		bne !-

line:

		ldy #9
		:wait()
		bit $24
		bit $24
		bit $24

		stx $d020
	//	inc $d021
		jmp endline

endline:

		lda ll+1
		clc
spd:
		adc #2
		sta ll+1

		bcc !+
		lda #$9b
		sta hibyte_top+1
!:

		lda hibyte_top+1
		cmp #$9b
		bne !+
		lda ll+1
		cmp #$23
		bcc !+

		lda #RED
		sta $d020

		:set_irq(intro_end_irq)
		jsr music.play
		jmp skp
!:

		:set_irq(bottom_border_irq)

.if(debug_music){inc $d020}
bottom_ply:
		jsr music.play
.if(debug_music){dec $d020}

		lda $d012
		bpl !+
		lda #BIT_ABS
		sta bottom_ply
		lda #$20 //JSR
		sta top_ply
!:

skp:
		:d011($9b)
		:d012($24)
		asl $d019

		cli

		fade_routine:
		jsr fade_basic_text


		lda reset_a
		ldx reset_x
		ldy reset_y
		rti

intro_end_irq:
		sta reset_a
		stx reset_x
		sty reset_y

fadesc:
		ldx #0
		lda screen_fade_table,x
sc:
		sta $d021
fdp:
		inc fadesc+1
		cpx #7
		bne !+
		lda #$04
		sta sc+1

		ldx #16
		lda #0
spr:
		sta $d000,x
		dex
		bpl spr

		inc intro_wait+1
!:

can_change_scr:
		lda #0
		beq nosc

		lda #0
		sta $bfff

		lda #$d8
		sta $d016

		lda #INTRO_SCREEN_d018
		sta $d018
		:bank_1()

		lda #$ff
		sta $d015

		:set_irq(bitmap_fade_irq)
		:d012($f9)
		:d011($3b)

		ldx #16
		lda #0
		sta block_sequence
		sta $d010
!:
		sta $d000,x
		dex
		bpl !-

		lda #RED
		ldx #8
!:
		sta $d027,x
		dex
		bpl !-

nosc:
.if(debug_music){inc $d020}
		jsr music.play
.if(debug_music){dec $d020}

		asl $d019

		lda reset_a
		ldx reset_x
		ldy reset_y
		rti

bottom_border_irq:
		:open_irq()

		asl $d019

		:set_irq(border_stabilizer_irq)
bop:
		lda #border_stabilizer_irq_line
		sta $d012

		lda #$1b
		sta $d011

		lda #0
		sta $d015

		:close_irq()
		rti

fade_basic_text:
		lda #0
		cmp #$17 //Delay prima di iniziare il fade
		bcs !+
		inc fade_basic_text+1
		rts
!:

		inc dly+1
dly:
		lda #0
		cmp #2
		beq !+
		rts
!:

		lda #0
		sta col_pt
		sta dly+1

!:
		ldx c_start
		lda column_sequence,x
		sta column

		ldx col_pt
		lda d800_fade_table,x
		sta colour

		jsr paint_column

		inc c_start
		inc col_pt

		lda col_pt
colnum:
		cmp #4
		bne !-

		inc giri+1
giri:
		lda #0
		cmp #43
		bmi !+
		lda #BIT_ABS
		sta fade_routine
		inc clear_screen_wait+1
!:
		rts

paint_column:

		lda #0
		sta tmp

		lda #$d8
		sta col_addr+2

		lda column
		cmp #39
		bcc !+
		beq !+
		rts
!:
		sta col_addr+1

rowloop:
		lda colour
col_addr:
		sta $d800

		clc
		lda col_addr+1
		adc #$28
		sta col_addr+1
		bcc !+
		inc col_addr+2
!:
		inc tmp
		lda tmp
		cmp #25
		bne rowloop

		rts

.align $3
d800_fade_table:
.byte BLUE,BROWN,DARK_GRAY,GRAY

.align $100
column_sequence:
.byte 0,0,0,0
.byte 0,0,0,1
.byte 0,0,1,2
.byte 0,1,2,3
.for(var x=0;x<=38;x++){
	.byte x+1,x+2,x+3,x+4
}

.align 20
screen_fade_table:
.byte PURPLE,LIGHT_BLUE,CYAN,LIGHT_GREEN,YELLOW,LIGHT_RED,ORANGE,RED
clear:
.text " "
clear_basic_screen:
		lda clear
		ldx #0
!:
		sta $0400,x
		sta $0500,x
		sta $0600,x
		sta $0700-8,x
		dex
		bne !-

		rts
