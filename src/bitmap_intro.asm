draw_fake_pic:

        ldx #0
!:
        lda #$22
        sta INTRO_SCREEN,x
        sta INTRO_SCREEN+$100,x
        sta INTRO_SCREEN+$200,x
        sta INTRO_SCREEN+$300,x

        lda #$0
        sta $d800,x
        sta $d800+$100,x
        sta $d800+$200,x
        sta $d800+$300,x

        dex
        bne !-


        lda #$55
!:
.for(var x=0;x<31;x++){
        sta $4000+x*$100,x
    }
        sta $5e40,x

        dex
        bne !-

        rts

draw_pic:

        ldx #0
!:
        lda pic+$1f40,x
        sta INTRO_SCREEN,x

        lda pic+$1f40+$100,x
        sta INTRO_SCREEN+$100,x

        lda pic+$1f40+$200,x
        sta INTRO_SCREEN+$200,x

        lda pic+$1f40+$300,x
        sta INTRO_SCREEN+$300,x

        lda pic+$2328,x
        sta $d800,x

        lda pic+$2328+$100,x
        sta $d800+$100,x

        lda pic+$2328+$200,x
        sta $d800+$200,x

        lda pic+$2328+$300,x
        sta $d800+$300,x

        dex
        bne !-

        rts

.macro add_16_bit_with_offset(column_lo,row_lo,column_hi,row_hi,target){
        clc
        lda column_lo,x
        adc row_lo,y
        sta target+1

        lda column_hi,x
        adc row_hi,y
        sta target+2
}

.macro add_offset_16_bit_val(val,offset){
        clc
        lda val+1
        adc #<offset
        sta val+1

        lda val+2
        adc #>offset
        sta val+2
}


draw_bmp_block:

        ldy block_sequence
block4:
        lda block_sequence_x,y //bmp_x+1
        sta bmp_x+1
block5:
        lda block_sequence_y,y //bmp_x+1
        sta bmp_y+1

bmp_x:
        ldx #0 //0 - 19
bmp_y:
        ldy #0 //0 - 12 ma occhio all'ultima riga

        :add_16_bit_with_offset(px_columns_src_lo,px_rows_src_lo,px_columns_src_hi,px_rows_src_hi,px_src)
        :add_16_bit_with_offset(px_columns_dst_lo,px_rows_dst_lo,px_columns_dst_hi,px_rows_dst_hi,px_dst)

        :add_16_bit_with_offset(colours_columns_src_lo,colours_rows_src_lo,colours_columns_src_hi,colours_rows_src_hi,col_src)
        :add_16_bit_with_offset(colours_columns_dst_lo,colours_rows_dst_lo,colours_columns_dst_hi,colours_rows_dst_hi,col_dst)

        :add_16_bit_with_offset(d8_columns_src_lo,d8_rows_src_lo,d8_columns_src_hi,d8_rows_src_hi,d8_src)
        :add_16_bit_with_offset(d8_columns_dst_lo,d8_rows_dst_lo,d8_columns_dst_hi,d8_rows_dst_hi,d8_dst)

        lda #$ff
        sta secnd+1

draw_2:
        ldx #15
!:
px_src:
        lda pic,x
px_dst:
        sta $4000,x
        dex
        bpl !-

        ldx #1
!:
col_src:
        lda pic+$1f40,x
col_dst:
        sta INTRO_SCREEN,x

d8_src:
        lda pic+$2328,x
d8_dst:
        sta $d800,x

        dex
        bpl !-

        inc secnd+1
secnd:
        lda #$ff
        bne end_drw

        lda bmp_y+1
        cmp #12
        beq end_drw

        //Disegno i secondi due
        :add_offset_16_bit_val(px_src,16*20)
        :add_offset_16_bit_val(px_dst,16*20)
        //--------
        :add_offset_16_bit_val(col_src,40)
        :add_offset_16_bit_val(col_dst,40)
        //--------
        :add_offset_16_bit_val(d8_src,40)
        :add_offset_16_bit_val(d8_dst,40)
        jmp draw_2
end_drw:
        clc
        lda block_sequence
        adc #1
        sta block_sequence
        bcc !+
        inc block0+2
        inc block1+2
        inc block2+2
        inc block3+2
        inc block4+2
        inc block5+2
        inc block6+2
        inc draw_end+1
!:

draw_end:
        lda #0
        beq !+
        lda block_sequence
        cmp #4
        bne !+
        //Fermo tutto l'effetto
        lda #STATE_WAITING
        sta trigger_state+1
        inc next_scene+1
!:
        rts

init_intro_sprite:

        ldx #8
!:
        lda #[intro_sprite/$40]
        sta INTRO_SCREEN+$03f8,x

        lda #1
        sta $d027,x
        dex
        bpl !-


        lda #0
        sta $d01c
        sta $d01d

        rts


.align 160
.pc = * "bmp address table"
.import source "data/bmp_screen_addresses.asm"

sprite_off_irq:
        sta reset_a
        stx reset_x
        sty reset_y

        lda #0
        sta sprite_select
        sta $d015

        :d012($30)
        :d011($3b)

irq_0_lo:
        lda #<bitmap_top_irq
        sta $fffe
irq_0_hi:
        lda #>bitmap_top_irq
        sta $ffff


        asl $d019
        cli
//---------------------------------
next_one:
        ldx sprite_select
        lda sprite_state,x
    //    cmp #STATE_DISABLED
    //    beq nomoves
        cmp #STATE_ARRIVED
        beq nomoves
ready:
        cmp #STATE_READY
        bne fading
        lda #1
        sta draw_busy
        jsr draw_next_sprite    //Disegno lo sprite
        jsr draw_bmp_block      //Disegno il bitmap

        ldx sprite_select
        lda #STATE_FADING
        sta sprite_state,x

        lda #0
        sta draw_busy
        jmp nomoves
fading:
        cmp #STATE_FADING
        bne moving
        jsr fade_sprite
        jmp nomoves
moving:
        cmp #STATE_MOVING
        bne nomoves
        jsr move_sprite
        jsr anim_sprite
nomoves:

        jsr enable_sprite_sequence
        inc sprite_select
        lda sprite_select
maxspr:
        cmp #1 //#8
        bne next_one
//--------------------------
//        asl $d019

        lda reset_a
        ldx reset_x
        ldy reset_y
        rti

bitmap_top_irq:
        sta reset_a
        sty reset_y

sprite_enabler:
        lda #$ff
        sta $d015
        :d012($f9)
        :d011($3b)

fx_irq_lo:
        lda #<bitmap_fade_irq
        sta $fffe
fx_irq_hi:
        lda #>bitmap_fade_irq
        sta $ffff

        asl $d019

        ldy #$20
        :wait()

        lda #0
        sta $d021


next_scene:
        lda #0
        beq !+

        inc endtl+1
endtl:
        lda #0
        cmp #delay_pre_dqtr_fade //Delay prima del fade DQTY
        bne !+
        :set_irq(sprite_flash_irq)

!:
        ldy reset_y
        lda reset_a
        rti


bitmap_fade_irq:
        sta reset_a
        stx reset_x
        sty reset_y

        lda #0
        sta $7fff

        lda #2
        sta $d021

        :bank_1()

        lda #$33
        sta $d011

        lda #$fc
!:
        cmp $d012
        bne !-
        lda #$9b
        sta $d011

        :d012($2c)
        :set_irq(sprite_off_irq)


.if(debug_music){inc $d020}
        jsr music.play
.if(debug_music){dec $d020}

        asl $d019

        lda reset_a
        ldx reset_x
        ldy reset_y
        rti

.align $8
sprite_x_pt:
.fill $8,0

.align $8
sprite_state:
.fill $8,STATE_READY
//.fill $,STATE_ARRIVED

.align $8
sprite_fade_pt:
.fill $8,0


.align $8
sprite_speed:
.fill $8,1

sprite_shift_speed:
.fill $8,0

.align $8
sprite_speed_eor:
.fill $8,0

.align $8
bottom_screen:
.fill $8,0

.align $8
sprite_direction:
.fill $8,0


d010_on:
.byte %00000001
.byte %00000010
.byte %00000100
.byte %00001000
.byte %00010000
.byte %00100000
.byte %01000000
.byte %10000000

d010_off:
.byte %11111110
.byte %11111101
.byte %11111011
.byte %11110111
.byte %11101111
.byte %11011111
.byte %10111111
.byte %01111111


.align $8
sprite_fade_tbl:
.byte $08,$0a,$0f,$07,$01,LIGHT_GRAY,LIGHT_RED,$08

draw_next_sprite:
        ldy sprite_select
        //Posiziono lo sprite
        lda #0
        sta bottom_screen,y

        lda #1
        sta sprite_speed,y

        ldx block_sequence
block0:
        lda block_sequence_x,x
block6:
        lda block_direction,x
        sta sprite_direction,y

        //Calcolo $d010
        //Se la dir è verso destra, siamo al sicuro
block1:
        lda block_sequence_x,x
        cmp #15
        bcs d010_yes
d010_no:
        lda $d010
        and d010_off,y
        jmp god010
d010_yes:
        lda $d010
        ora d010_on,y
god010:
        sta $d010

        tya
        asl
        tay
block2:
        lda block_sequence_x,x
        asl
        asl
        asl
        asl
        clc
        adc #20
        sta $d000,y
block3:
        lda block_sequence_y,x
        asl
        asl
        asl
        asl
        clc
        adc #48
        sta $d001,y

        rts
//---------------------------------------
fade_sprite:
        ldx sprite_select
        ldy sprite_fade_pt,x
        lda sprite_fade_tbl,y
        sta $d027,x

        inc sprite_fade_pt,x
        lda sprite_fade_pt,x
        cmp #8
        bne !+
        //Finito il fade posso avviarlo per il movimento
        lda #0
        sta sprite_fade_pt,x

after_fade_state:
        lda #STATE_MOVING
        sta sprite_state,x

        //E all'inizio abilito pure il prox sprite (per non farli partire tutti insieme)
enable_nxt:
        jsr turn_on_sprites
!:
        rts

//----------------------------------------------
move_sprite:
    //    ldy #0
    //    ldx #0
        lax sprite_select
        asl
        tay
nextspr:
        //lda is_sprite_fading,y
        //bne skip

        //Capisco se la dir è verso DX (0) o verso SX (1)
        lda sprite_direction,x
        bne indietro

avanti:
        lda #<move_avanti
        sta move_func+1
    //    lda #>move_avanti
    //    sta move_func+2
        jmp enddir
indietro:
        lda #<move_indietro
        sta move_func+1
    //    lda #>move_indietro
    //    sta move_func+2
enddir:
        clc
        lda sprite_shift_speed,x
        adc #1
        sta sprite_shift_speed,x

        lda sprite_speed_eor,x
        clc
        adc #1
noxspeed:
        cmp #4 //Ogni quanto aumentare la speed di caduta
        bne nospeed

        clc
        lda sprite_speed,x
        adc #4 //Di quanto aumentare la speed di caduta
        sta sprite_speed,x

        lda #0
nospeed:
        sta sprite_speed_eor,x

move_func:
        jsr move_avanti

        lda $d001,y
        clc
        adc sprite_speed,x
        sta $d001,y
        bcc skip
        //Crossato il bordo?
        lda #1
        sta bottom_screen,x
skip:

        //Controllo il bordo
        lda bottom_screen,x
        beq !+
        //Ok sono nel bordo
        lda $d001,y
        cmp #$2a
        bcc !+ //finito! resetto le tabelle di speed e il colore

        lda #0
        sta sprite_speed_eor,x
        sta sprite_shift_speed,x
        sta $d000,y
        sta bottom_screen,x
        sta eor_anim_sprite,x
        lda #RED
        sta $d027,x

         //Resetto il frame
        lda #[intro_sprite/$40]
        sta INTRO_SCREEN+$03f8,x

        //e lo rimetto in WAITING
        lda #STATE_ARRIVED
        sta sprite_state,x

        lda $d010
        and d010_off,x
        sta $d010
!:
//        ldx sprite_select
        rts

.align $40
move_avanti:

        clc
        //sty $10
        stx $11
        lda sprite_shift_speed,x
        tax
        lda x_fall,x
        ldx $11
        adc $d000,y
        pha
        bcc !+
        //Crossed $ff ?
        lda $d010
        ora d010_on,x
        sta $d010
!:
        pla
        sta $d000,y

        rts

move_indietro:

        sec
        //sty $10
        stx $11
        lda sprite_shift_speed,x
        tax
        lda $d000,y
        sbc x_fall,x
        pha
        ldx $11

        bcs !+
        //Crossed $ff ?
        lda $d010
        and d010_off,x
        sta $d010
!:
        pla
        sta $d000,y

        rts

enable_sprite_sequence:

        lda draw_busy
        beq !+
        rts
!:
        ldx sprite_select
        lda sprite_state,x
        cmp #STATE_ARRIVED
        beq !+

        rts
!:
trigger_state:
        lda #STATE_READY
        sta sprite_state,x
    //    inc $d020
        rts

turn_on_sprites:
        inc maxspr+1
        lda maxspr+1
        cmp #8
        bne !+
        lda #BIT_ABS
        sta enable_nxt
!:
        rts

turn_on_sprites_outro:

        inc o_maxspr+1
        lda o_maxspr+1
        cmp #8
        bne !+
        lda #BIT_ABS
        sta enable_nxt
!:
        rts

.align $8
eor_anim_sprite:
.fill $8,2

anim_sprite:
        //Animo
        lda eor_anim_sprite,x
        clc
        adc #1
        sta eor_anim_sprite,x
        cmp #4
        beq !+
        rts
!:
        lda #0
        sta eor_anim_sprite,x

        lda INTRO_SCREEN+$03f8,x

        clc
        adc #1
        cmp #[intro_sprite/$40]+3
        bne !+
        lda #[intro_sprite/$40]
!:
//       and #3
        sta INTRO_SCREEN+$03f8,x
        rts

.align $100
.pc = * "x_sprite_osc"
x_fall:
.import source "data/x_fall.asm"


sprite_flash_irq:
        sta reset_a
        stx reset_x
        sty reset_y

end_irq_lo:
        lda #<sprite_flash_irq
        sta $fffe
end_irq_hi:
        lda #>sprite_flash_irq
        sta $ffff

label_fnc:
        jsr enable_label_sprites

        asl $d019

        jsr music.play

        lda reset_a
        ldx reset_x
        ldy reset_y
        rti

enable_label_sprites:

        ldx #0
        stx $d010
        lda #[doty_label_sprites/$40]
!:
        sta INTRO_SCREEN+$03f8,x
        inx
        clc
        adc #1
        cmp #[doty_label_sprites/$40]+4
        bne !-

        ldx #4

    !:
        lda #YELLOW
        sta $d027,x
        dex
        bpl !-

        lda #$98
        sta $d000

        lda #$af
        sta $d001
        sta $d003
        sta $d005
        sta $d007

        lda #$aa
        sta $d002

        lda #$c0
        sta $d004

        lda #$cc
        sta $d006

        lda #$0f
        sta $d015

        lda #<fade_label_sprites
        sta label_fnc+1

        rts

fade_label_sprites:
        lda #0
        bne gofade

timer:
        lda #0
        clc
        adc #1
        sta timer+1
        cmp #$52
        bne !+
        lda #1
        sta fade_label_sprites+1
!:
        rts

gofade:
        ldx #0
fadetl:
        ldy label_fade_pt,x
        lda label_fade,y
        sta $d027,x
        inc label_fade_pt,x
        lda label_fade_pt,x
        cmp #35
        bne !+
        lda #0
        sta label_fade_pt,x
!:
        inx
        cpx #4
        bne fadetl

        inc nxtt+1
nxtt:
        lda #0
        cmp #30
        bne !+
        /*
        lda #0
        sta timer+1
        sta fade_label_sprites+1
        sta nxtt+1

        lda #YELLOW
        sta $d027
        sta $d028
        sta $d029
        sta $d02a
        lda #BIT_ABS
        sta label_fnc
        */
        jsr reinit_fade_routine

        lda #<outro_fade_irq
        sta end_irq_lo+1

        lda #>outro_fade_irq
        sta end_irq_hi+1
!:

        rts
nullfunc:
        rts

.align $4
label_fade:
.byte YELLOW,YELLOW,YELLOW
.byte LIGHT_RED,LIGHT_RED,LIGHT_RED
.byte ORANGE,ORANGE,ORANGE
.byte RED,RED,RED
.byte BROWN,BROWN,BROWN
.byte BROWN,BROWN,BROWN
.byte BROWN,BROWN,BROWN
.byte RED,RED,RED
.byte ORANGE,ORANGE,ORANGE
.byte LIGHT_RED,LIGHT_RED,LIGHT_RED
.byte YELLOW,YELLOW,YELLOW
.byte YELLOW,YELLOW,YELLOW

.align $4
label_fade_pt:
.byte $8,$5,$3,$0

//------------------------
//Outro stuff
//------------------------
reinit_fade_routine:
        lda #0
        sta block_sequence
        sta $d015
        sta draw_busy
        sta $d010


        ldx #8
        ldy #0
!:
        lda #0
        sta sprite_fade_pt,x
        sta $d000,y
        iny
        iny

        lda #[intro_sprite/$40]
        sta INTRO_SCREEN+$03f8,x

        lda #STATE_READY
        sta sprite_state,x
        dex
        bpl !-

        lda #$ff
        sta $d015

        dec block0+2
        dec block1+2
        dec block2+2
        dec block3+2

        //Codice
        lda #$20 //JSR
        sta enable_nxt

        lda #STATE_READY
        sta after_fade_state+1

        :set_addr(turn_on_sprites_outro,enable_nxt)
        rts


outro_top_irq:
        sta reset_a
        sty reset_y
sprite_trg:
        lda #$ff
        sta $d015

        ldy #49
        :wait()

        lda #0
        sta $d021

        asl $d019

        :d012($f9)
        :set_irq(outro_fade_irq)
        lda reset_a
        ldy reset_y
        rti

outro_fade_irq:
        sta reset_a
        stx reset_x
        sty reset_y

        lda #$33
        sta $d011

        lda #RED
        sta $d021

        lda #$fc
!:
        cmp $d012
        bcs !-

        lda #$3b
        sta $d011

        :d012($30)
        :set_irq(outro_top_irq)

        ldy #$50
        :wait()

        lda #0
        sta $d015

wait_outro:
        lda #0
        bne offs_x
pdlr:
        lda  #0
        inc pdlr+1
        cmp #delay_post_dqtr_fade
        bne !+
        inc wait_outro+1

!:
        jmp endoutro

offs_x:
        lda #0
        sta sprite_select

//---------------------------------
o_next_one:
        ldx sprite_select
        lda sprite_state,x
o_ready:
        cmp #STATE_READY
        bne o_fading
        lda #1
        sta draw_busy

        lda $d010
        and d010_off,x
        sta $d010

kill_me1:
        jsr draw_next_sprite    //Disegno lo sprite
kill_me2:
        jsr erase_bmp_block     //Cancello il bitmap

        ldx sprite_select
        lda #STATE_FADING
        sta sprite_state,x

        lda #0
        sta draw_busy
        jmp o_nomoves
o_fading:
        cmp #STATE_FADING
        bne o_nomoves
        jsr fade_sprite
        //jmp o_nomoves
o_nomoves:
        jsr enable_sprite_sequence
        inc sprite_select
        lda sprite_select
o_maxspr:
        cmp #1 //#8
        bne o_next_one
//--------------------------
//        asl $d019
gokill_intro:
        lda #0
        beq !+
finalwt:
        lda #0
        inc finalwt+1
        cmp #7
        bne !+

        :set_irq(transition_irq)    //transition.asm
        :d012($f9)
        lda #0
        sta $d015
        sta $d011

        sta sprite_trg+1
!:

endoutro:
        asl $d019
        .if(debug_music){inc $d020}
        jsr music.play
        .if(debug_music){dec $d020}
        lda reset_a
        ldx reset_x
        ldy reset_y
        rti


erase_bmp_block:

        ldy block_sequence
o_block4:
        lda block_sequence_x,y //bmp_x+1
        sta o_bmp_x+1
o_block5:
        lda block_sequence_y,y //bmp_x+1
        sta o_bmp_y+1

o_bmp_x:
        ldx #0 //0 - 19
o_bmp_y:
        ldy #0 //0 - 12 ma occhio all'ultima riga

    //    :add_16_bit_with_offset(o_px_columns_src_lo,o_px_rows_src_lo,o_px_columns_src_hi,o_px_rows_src_hi,o_px_src)
        :add_16_bit_with_offset(px_columns_dst_lo,px_rows_dst_lo,px_columns_dst_hi,px_rows_dst_hi,o_px_dst)

    //    :add_16_bit_with_offset(o_colours_columns_src_lo,o_colours_rows_src_lo,o_colours_columns_src_hi,o_colours_rows_src_hi,col_src)
        :add_16_bit_with_offset(colours_columns_dst_lo,colours_rows_dst_lo,colours_columns_dst_hi,colours_rows_dst_hi,o_col_dst)

    //    :add_16_bit_with_offset(o_d8_columns_src_lo,o_d8_rows_src_lo,o_d8_columns_src_hi,o_d8_rows_src_hi,o_d8_src)
        :add_16_bit_with_offset(d8_columns_dst_lo,d8_rows_dst_lo,d8_columns_dst_hi,d8_rows_dst_hi,o_d8_dst)

        lda #$ff
        sta o_secnd+1

o_draw_2:
        ldx #15
        lda #$55
!:
o_px_dst:
        sta $4000,x
        dex
        bpl !-

        ldx #1
!:

        lda #$22
o_col_dst:
        sta INTRO_SCREEN,x

        lda #$0
o_d8_dst:
        sta $d800,x

        dex
        bpl !-

        inc o_secnd+1
o_secnd:
        lda #$ff
        bne o_end_drw

        lda o_bmp_y+1
        cmp #12
        beq o_end_drw

        //Disegno i secondi due
        //:add_offset_16_bit_val(px_src,16*20)
        :add_offset_16_bit_val(o_px_dst,16*20)
        //--------
        //:add_offset_16_bit_val(col_src,40)
        :add_offset_16_bit_val(o_col_dst,40)
        //--------
        //:add_offset_16_bit_val(d8_src,40)
        :add_offset_16_bit_val(o_d8_dst,40)
        jmp o_draw_2
o_end_drw:
        clc
        lda block_sequence
        adc #1
        sta block_sequence
        bcc !+

        inc o_block4+2
        inc o_block5+2
        inc o_draw_end+1
!:

o_draw_end:
        lda #0
        beq !+
        lda block_sequence
        cmp #3
        bne !+


    //    inc $d020
        //Fermo tutto l'effetto
        lda #$3
        sta offs_x+1
        lda #STATE_WAITING
        sta trigger_state+1
        inc next_scene+1

        lda #$70
        sta $d015
        sta sprite_trg+1

        lda #RED
        sta $d027
        sta $d02a
        sta $d02b

        lda #BIT_ABS
        sta kill_me1
        sta kill_me2

        inc gokill_intro+1
!:
        rts
