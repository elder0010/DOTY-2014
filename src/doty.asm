//DEMO OF THE YEAR INVITATION
.import source "../common/functions.asm"
.import source "variables.asm"
.var music = LoadSid("data/music.sid")
.pc=music.location "Music" .fill music.size, music.getData(i)

//:BasicUpstart2(code)

.macro LoadSpriteFromPicture(filename) {
	.var picture = LoadPicture(filename, List().add($000000, $b8c76f,$6c6c6c,$959595))
	.for (var y=0; y<21; y++)
		.for (var x=0; x<3; x++)
			.byte picture.getSinglecolorByte(x,y)
	.byte 0
}

.pc = intro_sprite "intro sprite"
.import binary "data/square_rotation.raw"
.pc = * "doty label sprites"
doty_label_sprites:
.import binary "data/bmp_sprites/doty_title.raw"


.pc = $7000 "eagle bitmap"
pic:
.import c64 "data/eagle.kla"

.pc = $c000 "start"
code:
		sei
		:kernal_off()
		jsr init_scene
		jsr reset_zp

		lda #15
		sta transition_step
		inc transition_running
	//	inc can_go_next_page

		cli

//.if(!skip_intro){
		jsr clear_screen_wait

go_init_transition:
		lda #0
		beq go_init_transition

		lda #0
		sta $d015

		jsr draw_cod_logo_pixels
		jsr relocate_stuff
		jsr generate_fade_charsets
	//	jsr init_sprites
		jsr point_horizontal_sprites
		jsr next_page

		lda charset_switcher_1+15
		sta screen
		sta d018_char_screen+1
		sta $d018

		jsr point_horizontal_sprites_transition
		jsr turn_on_screen_transition

premain:
		lda #0
		beq premain

		jsr fill_text_colorram

main:
		lda can_go_next_page
		beq main

		dec can_go_next_page
		jsr next_page
		//Wait until the transition is finished
		//to allow a new screen draw
!:
		lda transition_running
		bne !-

		jmp main

.align $50
stabilizer_irq:
		sta reset_a
        stx reset_x
        sty reset_y

		lda #<stabilized_irq
		sta $fffe

		lda screen
		sta $d018

		inc $d012
		inc $d012

		asl $d019
		tsx

		lda #3
		sta $dd00

		cli

		.for(var n=0;n<32;n++){
			nop
		}

		brk

stabilized_irq:
		txs
		ldx #$8
!:		dex
		bne !-

		bit $ea
		nop

		lda #stabilizer_irq_line+1
		cmp $d012
		beq !+
!:
.pc = * "sideborder routine"
		.import source "sideborder.asm"

		lda #$0
		sta $d015

		lda #bottom_sprites_y
		sta $d001
		sta $d003
		sta $d005
		sta $d007
		sta $d009
		sta $d00b

		lda #$00
		sta $d010

//----inizio bordo--------
		lda #$fc
!:
		cmp $d012
		bcs !-

		lda #$1b
		sta $d011

		:reposition_sprites_x()

		asl $d019
		:d012($00)
		:d011($9b)

		:set_irq(music_irq)
		lda #$7f
		sta $d015

		lda #LOW_SCREEN_1_d018
		sta $d018

		ldx #1
		:wt(4)
		nop
		nop
		stx $dd00

		lda #$0
		sta $d017

		lda reset_a
		ldx reset_x
		ldy reset_y

		rti

music_irq:
		:open_irq()

		lda #$d8
		sta $d016

		lda #HORIZONTAL_SPRITES_COLOUR
		sta $d02b
		sta $d02c

		asl $d019

		:d012($4)
		:set_irq(top_sprite_replace_irq)

		//is the screen busy? no flip then
		lda transition_running
		bne no_space

		//Spacebar check to flip the page
dc0v:
		lda #$7f
sp_op0:
		bit $dc00	//sta
sp_op1:
		bit $dc01	//lda
		and #$10
		bne no_space

		//enable flipping
		lda #1
		sta can_go_next_page
		sta transition_running
no_space:

		lda transition_running
		beq !+
		jsr chars_transition
!:

		cli
		jsr music.play

blgo:
		lda #0
		beq noblink

		lda #LIGHT_GRAY
		jsr blink_column

		lda blink_column+1
		clc
adclm:
		adc #0
		sta blink_column+1
		tay

		lda #1
		sta adclm+1

		lda #WHITE
		jsr blink_column
skpx:

		cpy #$28

		bne !+
		jsr reset_blinker
!:

noblink:
		:close_irq()
		rti

reset_blinker:
		lda #$00
		sta blgo+1
		sta adclm+1

		lda #$0
		sta blink_column+1
		lda #LIGHT_GRAY
		jsr blink_column
		rts

top_sprite_replace_irq:
		sta reset_a
		stx reset_x
		sty reset_y
		lda #$ff
		sta $d015
		lda #top_sprites_y
		jsr reposition_sprites_y

		:d011($1b)
		:d012($28)

		:set_irq(screen_switcher_irq)
		asl $d019
bmp_transition_func:
		jsr bmp_column_draw
	//	lda #0
	//	sta page_pt
	//	sta transition_step
	//	sta	transition_running

		lda reset_a
		ldy reset_y
		ldx reset_x
		rti

screen_switcher_irq:
		:open_irq()

		asl $d019

		lda #$ff
		sta $d01d

		lda #$0
		sta $d017

		//Sprite X (repos)
left_col_x:
		lda #left_column_x
		sta $d008
		sta $d00c
right_col_x:
		lda #right_column_x
		sta $d00a
		sta $d00e
		
column_d010:
		lda #$f0 //#$f0
		sta $d010

		lda #sprite_y_start
		sta $d009
		sta $d00b

		lda #$ff
		sta $d00d
		sta $d00f

		lda #$f0
		sta $d015
column_colour:
		lda #RED //VERTICAL_SPRITES_COLOUR
		sta $d02b
		sta $d02c
		sta $d02d
		sta $d02e

		//Sprite PT

		lda #[bmp_screen_sprites/$40]
		sta SCREEN_1+$03fc
		sta SCREEN_2+$03fc
		sta COD_BMP_SCREEN_1+$03fc
		sta COD_BMP_SCREEN_2+$03fc

		lda #[bmp_screen_sprites/$40]
		sta SCREEN_1+$03fd
		sta SCREEN_2+$03fd
		sta COD_BMP_SCREEN_1+$03fd
		sta COD_BMP_SCREEN_2+$03fd

	//	lda #SCREEN_1_d018
		lda #COD_SCREEN_d018
		sta screen
		sta $d018

		:d012(stabilizer_irq_line)
		:d011($3b)
		:set_irq(stabilizer_irq)

column_transition_func:
		jsr column_fade

		:close_irq()
		rti

//Intro sequence
clear_screen_wait:
		lda #0
		beq clear_screen_wait
		jsr clear_basic_screen

intro_wait:
		lda #0
		beq intro_wait

		jsr draw_fake_pic
		jsr init_intro_sprite
		inc can_change_scr+1
		rts

allow_charset_transition:
		lda #0
		sta transition_step
		inc transition_running

//inc can_go_next_page
		rts

.pc = $c00 "intro"
.import source "intro.asm"


.pc = $a100 "sprites"
sprites_src:
horizontal_sprites_src:
:LoadSpriteFromPicture("data/column_sprites/horizontal/tile0.gif")
:LoadSpriteFromPicture("data/column_sprites/horizontal/tile1.gif")
:LoadSpriteFromPicture("data/column_sprites/horizontal/tile2.gif")
:LoadSpriteFromPicture("data/column_sprites/horizontal/tile3.gif")
:LoadSpriteFromPicture("data/column_sprites/horizontal/tile4.gif")
:LoadSpriteFromPicture("data/column_sprites/horizontal/tile5.gif")

.align $40*9
vertical_sprites_src:
:LoadSpriteFromPicture("data/column_sprites/vertical/tile0.gif")
:LoadSpriteFromPicture("data/column_sprites/vertical/tile1.gif")
:LoadSpriteFromPicture("data/column_sprites/vertical/tile2.gif")
:LoadSpriteFromPicture("data/column_sprites/vertical/tile3.gif")
:LoadSpriteFromPicture("data/column_sprites/vertical/tile4.gif")
:LoadSpriteFromPicture("data/column_sprites/vertical/tile5.gif")
:LoadSpriteFromPicture("data/column_sprites/vertical/tile6.gif")
:LoadSpriteFromPicture("data/column_sprites/vertical/tile7.gif")
:LoadSpriteFromPicture("data/column_sprites/vertical/tile8.gif")
:LoadSpriteFromPicture("data/column_sprites/vertical/tile9.gif")

.pc = $2d00 "charset"
charset_src:
.import c64 "data/charset.prg"

.pc = $3000 "bitmap fade routine"
.import source "bitmap_intro.asm"
.import source "data/bitmap_fall_sequence.asm"

.pc = $9800 "text transition sine"
.import source "data/mini_sine.asm"

.align $100
.pc = * "cod - d800 and screen col"
cod_screen_d800:
.import binary "data/cod_screen_d800.raw"

.pc = $e000 "text"
.import source "data/text.asm"

.pc = $a700 "cod - pixels"
cod_pixels:
.import c64 "data/cod_pixels.raw"

.pc = $f800 "functions"
.import source "functions.asm"

.pc = * "transition routine"
.import source "transition.asm"
