reset_zp:
		lda #0
		sta col_ct
		sta c_start
		sta col_pt
		sta can_go_next_page
		sta screen_busy
		sta page_pt
		sta page_flip
		sta transition_step
		sta transition_running

		lda #%00000010
		sta bank

		lda charset_switcher_1
		sta screen

		rts

init_scene:
		:turn_off_cia_turn_on_raster_irq()
		:kill_nmi()
		lax #0
		tay
		jsr music.init
		:d012($fc)
		:d011($1b)
		.if (skip_intro){
			:set_irq(music_irq)

			jsr clear_screen

			lda #BG_COLOUR
			sta $d021
			lda #BORDER_COLOUR
			sta $d020
		}else{
			:set_irq(intro_music_irq)
		}

		lda #$0
		sta $d015

		rts

point_horizontal_sprites:
		ldx #0
		lda #[sprites_horizontal/$40]
!:
		sta LOW_SCREEN_1+$03f8,x
		sta LOW_SCREEN_2+$03f8,x
		clc
		adc #1
		inx
		cpx #8
		bne !-

		rts

.align $10
sprite_y:
.for(var s=0;s<10;s++){
	.byte sprite_y_start+[21*s]
}


fill_text_colorram:
		ldx #0
		lda #MAIN_TEXT_COLOUR
!:

	//	sta $d800+$100,x
		sta $d800+$200,x
		sta $d800+$300,x
		dex
		bne !-

		ldx #$76
!:
		sta $d800+$200-$76,x
		dex
		bpl !-
		rts


reposition_sprites_y:

		sta $d001
		sta $d003
		sta $d005
		sta $d007
		sta $d009
		sta $d00b

		lda #$20
		sta $d010

		rts

.macro reposition_sprites_x(){

		lda #horizontal_sprites_x
		sta $d000

		lda #horizontal_sprites_x+48*1
		sta $d002

		lda #horizontal_sprites_x+48*2
		sta $d004

		lda #horizontal_sprites_x+48*3
		sta $d006

		lda #horizontal_sprites_x+48*4
		sta $d008

		lda #horizontal_sprites_x+48*5
		sta $d00a

}

next_page:
//------------------------------------
//Point the current page (source)
		ldx page_pt

		clc
		lda pages_addr_hi,x
		sta d_src_0+2
		adc #1
		sta d_src_1+2
		adc #1
		sta d_src_2+2

		lda pages_addr_lo,x
		sta d_src_0+1
		sta d_src_1+1
		sta d_src_2+1

//------------------------------------
.const line_scr_offs = 10*40
//------------------------------------
//Point the current screen (dest)
		lda page_flip
		eor #$ff
		sta page_flip
		beq w_screen_2
w_screen_1:
		:set_addr(line_scr_offs+SCREEN_1,d_dst_0)
		:set_addr(line_scr_offs+SCREEN_1+$100,d_dst_1)
		:set_addr(line_scr_offs+SCREEN_1+$200,d_dst_2)
		jmp endw
w_screen_2:
		:set_addr(line_scr_offs+SCREEN_2,d_dst_0)
		:set_addr(line_scr_offs+SCREEN_2+$100,d_dst_1)
		:set_addr(line_scr_offs+SCREEN_2+$200,d_dst_2)

endw:
//-------------------------------------

		ldx #0
!:
d_src_0:
		lda page_0,x
d_dst_0:
		sta SCREEN_1,x

d_src_1:
		lda page_0+$100,x
d_dst_1:
		sta SCREEN_1+$100,x

d_src_2:
		lda page_0+$200,x
d_dst_2:
		sta SCREEN_1+$200,x

		dex
		bne !-

		//Move to the next page
		clc
		lda page_pt
		adc #1
		cmp #13
		bne !+

		lda #0
!:
		sta page_pt
		rts

.align 28
pages_addr_lo:
.byte <page_0,<page_0,<page_0,<page_0,<page_0,<page_0,<page_0,<page_0,<page_0,<page_0,<page_0,<page_0,<page_0

pages_addr_hi:
.byte >page_0,>page_1,>page_2,>page_3,>page_4,>page_5,>page_6,>page_7,>page_8,>page_9,>page_10,>page_11,>page_12


generate_fade_charsets:
		lda #0
		sta char_ct+1

char_sw:
		ldx #0
		lda charset_dst_lo,x
		sta cur_char_dst+1

		lda charset_dst_hi,x
		sta cur_char_dst+2

char_loop:
		ldx #8
!:
cur_char_src:
		lda charset_1,x
cur_step:
		and f_step_0,x
cur_char_dst:
		sta charset_1_0,x
		dex
		bpl !-

		:next_char(cur_char_src)
		:next_char(cur_char_dst)

		inc char_ct+1
char_ct:
		lda #0
		cmp #$80
		bne char_loop

		//Move to the next charset
		inc char_sw+1
		lda char_sw+1
		cmp #3
		beq !+
		:set_addr(charset_1,cur_char_src)
		:next_step(cur_step)
		jmp generate_fade_charsets
!:

		//Fillo l'ultimo charset a 0
		lda #0
		ldx #0
!:
.for(var x=0;x<8;x++){
		sta charset_1_3+[x*$100],x
}
		dex
		bne !-
		rts

.align $20
charset_dst_lo:
.byte <charset_1_0,<charset_1_1,<charset_1_2,<charset_1_3

charset_dst_hi:
.byte >charset_1_0,>charset_1_1,>charset_1_2,>charset_1_3

.macro next_char(addr){
		clc
		lda addr+1
		adc #8
		sta addr+1
		bcc !+
		inc addr+2
!:
}

.macro next_step(addr){
		clc
		lda addr+1
		adc #8
		sta addr+1
		bcc !+
		inc addr+2
!:
}

.pc = * "fade charsets"
.import source "data/fade_charsets.asm"

chars_transition:
		lda #0
		eor #$ff
		sta *-3
		beq t_cnt
		rts
t_cnt:
		ldx transition_step
		lda text_sine,x
		tax
charset_s:
		lda charset_switcher_1,x
		sta screen
		sta d018_char_screen+1
		inc transition_step
		lda transition_step

		cmp #16
		bne endt
		//reached 16?
		//Time to switch the screen!
		lda page_flip
		beq change_s_2
change_s_1:
		:set_addr(charset_switcher_1,charset_s)
		jmp endt
change_s_2:
		:set_addr(charset_switcher_2,charset_s)
endt:
		cmp #32
		bne still_no_end
		lda #0
		sta transition_running
		//sta can_go_next_page
		sta screen_busy
		sta transition_step
		sta $dc01

		inc blgo+1

		lda #0
		sta blink_column+1

still_no_end:
		//lda #0
		//sta transition_step
		rts


.align $10
charset_switcher_1:
:get_d018_charset(SCREEN_1,charset_1)
:get_d018_charset(SCREEN_1,charset_1_0)
:get_d018_charset(SCREEN_1,charset_1_1)
:get_d018_charset(SCREEN_1,charset_1_2)
:get_d018_charset(SCREEN_1,charset_1_3)

charset_switcher_2:
:get_d018_charset(SCREEN_2,charset_1)
:get_d018_charset(SCREEN_2,charset_1_0)
:get_d018_charset(SCREEN_2,charset_1_1)
:get_d018_charset(SCREEN_2,charset_1_2)
:get_d018_charset(SCREEN_2,charset_1_3)

draw_cod_logo:
			ldx #$0
!:

.for(var x=0;x<13;x++){
			lda cod_pixels+x*$100,x
			sta $2000+x*$100,x
}

			lda cod_screen_d800,x
			sta COD_BMP_SCREEN_1,x
			sta COD_BMP_SCREEN_2,x

			lda cod_screen_d800+$88,x
			sta COD_BMP_SCREEN_1+$88,x
			sta COD_BMP_SCREEN_2+$88,x

			lda cod_screen_d800+$3e8,x
			sta $d800,x

			lda cod_screen_d800+$3e8+$88,x
			sta $d800+$88,x

			dex
			bne !-

			rts


blink_column:
			ldx #0
			pha
can_blink_col:
			lda #0
			bne !+
			pla
			rts
!:
			pla

.for(var x=10;x<25;x++){
			sta $d800+x*$28,x
}

			rts


.pc = * "relocate debug"
relocate_stuff:
//Charset

		ldx #0
!:
.for(var c=0;c<=6;c++){
		lda charset_src+[c*$100],x
		eor #$ff
		sta charset_1+[c*$100],x
}
		dex
		bne !-

//Sprites
		ldx #0
!:
.for(var c=0;c<=2;c++){
		lda vertical_sprites_src+[c*$100],x
		sta sprites_1+[c*$100],x
		sta bmp_screen_sprites+[c*$100],x
}

.for(var c=0;c<=2;c++){
		lda horizontal_sprites_src+[c*$100],x
		sta sprites_horizontal+[c*$100],x
		sta horizontal_sprites_transition_location+[c*$100],x
}
		dex
		bne !-

		rts
