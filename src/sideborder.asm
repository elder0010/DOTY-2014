.macro wt(num){
	ldy #num
	:wait()
}
.macro border(){
	sta $d016
	ror $d016
}

.macro border_hires(){

	sta $d016
	rol $d016

}

.macro screen_debug(){
	sta $d021
	inc $d021
}
.macro border_debug(){
	sta $d020
	inc $d020
}

.macro repos_and_border(mul,sprite_sel,hires){
	ldy #sprite_y_start+21*mul

	.if(sprite_sel==7){
		sty $d00d
		sty $d00f
	}else{
		sty $d009
		sty $d00b
	}

	:wt(7)
	.if(!hires){
		:border()
	}else{
		:border_hires()
	}

}


.macro next_sprite_and_border(offset,sprite_sel,hires){

		ldy #[bmp_screen_sprites/$40]+offset
		.if(sprite_sel==7){
				sty COD_BMP_SCREEN_1+$03fe
				sty COD_BMP_SCREEN_2+$03fe
				sty SCREEN_1+$03fe
				sty SCREEN_2+$03fe
		}else{
				sty COD_BMP_SCREEN_1+$3fc
				sty COD_BMP_SCREEN_2+$3fc
				sty SCREEN_1+$3fc
				sty SCREEN_2+$3fc
		}

		ldy #[bmp_screen_sprites/$40]+offset
		.if(sprite_sel==7){

				sty COD_BMP_SCREEN_1+$03ff
				sty COD_BMP_SCREEN_2+$03ff
				sty SCREEN_1+$03ff
				sty SCREEN_2+$03ff

			}else{
				sty COD_BMP_SCREEN_1+$3fd
				sty COD_BMP_SCREEN_2+$3fd
				sty SCREEN_1+$3fd
				sty SCREEN_2+$3fd
		}

		:wt(1)
		nop
		nop
		.if(!hires){
			:border()
		}else{
			:border_hires()
		}
}

		lda #$f6
.pc = * "sideborder routine start"
!:
		ldx $d012
		cpx #$34
		bne !-

		:wt(8)
		:border()

		:wt(10)
		nop
		:border()

		:wt(9)
		:border()

		:wt(7)
		nop
		nop
		:border()

.for(var x=0;x<3;x++){
		:wt(9)
		:border()
}
		bit $24
		:border()

.for(var x=0;x<2;x++){
		:wt(9)
		:border()
}
		:repos_and_border(1,7,false)
		:next_sprite_and_border(1,7,false)
//------------------------------------
.for(var x=0;x<3;x++){
		:wt(9)
		:border()
}
		bit $24
		:border()

.for(var x=0;x<7;x++){
		:wt(9)
		:border()
}
		bit $24
		:border()

.for(var x=0;x<7;x++){
		:wt(9)
		:border()
}
		bit $24
		:border()

		:repos_and_border(2,6,false)
		:next_sprite_and_border(2,6,false)
//-----------------------------------

.for(var x=0;x<5;x++){
		:wt(9)
		:border()
}
		bit $24
		:border()

.for(var x=0;x<7;x++){
		:wt(9)
		:border()
}
		bit $24
		:border()

		:repos_and_border(3,7,false)
		:next_sprite_and_border(3,7,false)

.for(var x=0;x<5;x++){
		:wt(9)
		:border()
}
		bit $24
		:border()
//----------------------------------
.for(var x=0;x<7;x++){
		:wt(9)
		:border()
}
		bit $24
		:border()

.for(var x=0;x<7;x++){
		:wt(9)
		:border()
}
		bit $24
		:border()

		:repos_and_border(4,6,false)
		:next_sprite_and_border(4,6,false)

.for(var x=0;x<4;x++){
		:wt(9)
		:border()
}

		lda #$4 //Cambio valore di $d016

		ldy #2
		sty $dd00

		:wt(3)

		bit $24
		bit $24
		clc
		nop

		ldy #$1b
		sty $d011

d018_char_screen:
		ldy #SCREEN_1_d018
		sty $d018

	//	:screen_debug()
		:border_hires()
//--------------------------------------

		bit $24
		:border_hires()

.for(var x=0;x<7;x++){
		:wt(9)
		:border_hires()
}

		bit $24
		:border_hires()

.for(var x=0;x<5;x++){
		:wt(9)
		:border_hires()
}
		:repos_and_border(5,7,true)
		:next_sprite_and_border(5,7,true)

		bit $24
		:border_hires()

.for(var x=0;x<7;x++){
		:wt(9)
		:border_hires()
}

		bit $24
		:border_hires()
//--------------------------------------
.for(var x=0;x<7;x++){
		:wt(9)
		:border_hires()
}
		bit $24
		:border_hires()

.for(var x=0;x<5;x++){
		:wt(9)
		:border_hires()
}
		:repos_and_border(6,6,true)
		:next_sprite_and_border(6,6,true)

		bit $24
		:border_hires()
//--------------------------------------
.for(var x=0;x<7;x++){
		:wt(9)
		:border_hires()
}
		bit $24
		:border_hires()

.for(var x=0;x<7;x++){
		:wt(9)
		:border_hires()
}
		bit $24
		:border_hires()

.for(var x=0;x<5;x++){
		:wt(9)
		:border_hires()
}
		:repos_and_border(7,7,true)
		:next_sprite_and_border(7,7,true)

		bit $24
		:border_hires()
//--------------------------------------
.for(var x=0;x<7;x++){
		:wt(9)
		:border_hires()
}
		bit $24
		:border_hires()

.for(var x=0;x<5;x++){
		:wt(9)
		:border_hires()
}
		:repos_and_border(8,6,true)
		:next_sprite_and_border(8,6,true)

		bit $24
		:border_hires()
//--------------------------------------
.for(var x=0;x<7;x++){
		:wt(9)
		:border_hires()
}
		bit $24
		:border_hires()

.for(var x=0;x<7;x++){
		:wt(9)
		:border_hires()
}
		bit $24
		:border_hires()

.for(var x=0;x<5;x++){
		:wt(9)
		:border_hires()
}
		:repos_and_border(9,7,true)
		:next_sprite_and_border(9,7,true)

		bit $24
		:border_hires()

.for(var x=0;x<7;x++){
		:wt(9)
		:border_hires()
}
		bit $24
		:border_hires()

.for(var x=0;x<4;x++){
		:wt(9)
		:border_hires()
}

		ldy #$13
		sty $d011

		:wt(7)
		nop
		nop

		:border_hires()

.for(var x=0;x<5;x++){
		:wt(9)
		:border_hires()
}
.pc = * "sideborder routine end"
