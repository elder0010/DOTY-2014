transition_irq_top:
        :open_irq()

top_sprites_top:
        lda #$78
        jsr reposition_sprites_y


bottom_lo:
        lda #$87
        sta $d012

bottom_hi:
        lda #$00
        sta $d011

        :set_irq(transition_irq)

        asl $d019
        :close_irq()
        rti

transition_irq:
        :open_irq()

    //    inc $d020
top_sprites_bottom:
        lda #$8e+5+5
        jsr reposition_sprites_y

    //    dec $d020

        lda #$f9
!:
        cmp $d012
        bne !-

d011_tp:
        lda #0 //#$17
        sta $d011

        lda #$fb
!:
        cmp $d012
        bcs !-
d011_bt:
        lda #0 //#$1b
        sta $d011


        inc go_init_transition+1

        lda #COD_SCREEN_d018
d018trg:
        sta $d018   //sta


d011trg:
        lda #0      //$3b
        sta $d011

sprtrg:
        lda #$0
        sta $d015

        :bank_0()

next_irq_d012:
        lda #$0
        sta $d012

        asl $d019

next_irq_lo:
        lda #<transition_irq_top
        sta $fffe
next_irq_hi:
        lda #>transition_irq_top
        sta $ffff

    //    inc $d020
        jsr music.play
    //    dec $d020

tr_func:
        jsr nofunc

        :close_irq()
        rti


point_horizontal_sprites_transition:

        ldx #8
        lda #RED
!:
        sta $d027,x
        dex
        bpl !-


        ldx #0
        lda #[horizontal_sprites_transition_location/$40]

!:
        sta COD_BMP_SCREEN_1+$03f8,x
        clc
        adc #1
        inx
        cpx #8
        bne !-

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

        lda #$58
        jsr reposition_sprites_y

        rts

draw_cod_logo_pixels:
        ldx #$0

!:

.for(var x=0;x<13;x++){
        lda cod_pixels+x*$100,x
        sta $2000+x*$100,x
}

        lda #$22
        sta COD_BMP_SCREEN_1,x
        sta COD_BMP_SCREEN_1+$100,x
        sta COD_BMP_SCREEN_1+$200,x
        sta COD_BMP_SCREEN_1+$300,x

        sta $d800,x
        sta $d800+$100,x
        sta $d800+$200,x
        sta $d800+$300,x

        dex
        bne !-

        //Clear also the last rows of the last page (facepalm)
        lda clearchr
        ldx #0
!:
        sta page_12+$1e0,x
        dex
        bne !-
        rts
clearchr:
.text " "

turn_on_screen_transition:
        lda #$1f
        sta d011trg+1
        sta bottom_hi+1
        sta d011_bt+1
        lda #$17
        sta d011_tp+1

        lda #STA_ABS
        sta d018trg

        lda #$3f
        sta sprtrg+1

        lda #$ff
        sta $d01d

        :set_addr(fade_tr_sprites,tr_func) //enable fade
        rts

.align $2
trans_y_pt:
.byte 0,0


.align 16*5
trans_y:
.byte 0,0,0,0,0,1,1,1,1,1,1,1,2,2,2,2
.byte 2,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4
.byte 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
.byte 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
.byte 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5


.align $12
sprite_tfade_tbl:
.byte RED,RED,ORANGE,ORANGE,GRAY,GRAY,LIGHT_RED,LIGHT_RED,LIGHT_GRAY,LIGHT_GRAY,YELLOW,YELLOW


fade_tr_sprites:
        ldy #2
        lda sprite_tfade_tbl,y

        ldx #8
!:
        sta $d027,x
        dex
        bpl !-

        inc fade_tr_sprites+1
        lda fade_tr_sprites+1
        cmp #12
        bne !+
        :set_addr(move_hor_sprites,tr_func)

!:
        rts

nofunc:
        rts

move_hor_sprites:

        lda trans_y
        sta tmp

        inc move_hor_sprites+1

        sec
        lda top_sprites_top+1
        sbc tmp
sup_op:
        sta top_sprites_top+1
        cmp #top_sprites_y
        bne !+
        lda #BIT_ABS
        sta sup_op
!:

        clc
        lda top_sprites_bottom+1
        adc tmp
inf_op:
        sta top_sprites_bottom+1
        cmp #bottom_sprites_y
        bne !+
        lda #BIT_ABS
        sta inf_op

        :set_addr(bmp_column_draw,tr_func)

        //Switcho irq
        :d012($4)
        :set_irq(top_sprite_replace_irq)


        lda #<top_sprite_replace_irq
        sta next_irq_lo+1

        lda #>top_sprite_replace_irq
        sta next_irq_hi+1
!:

        rts


column_fade:

        ldy #0
        lda sprite_tfade_tbl,y

        sta column_colour+1

        inc column_fade+1
        lda column_fade+1
        cmp #12
        bne !+
        :set_addr(nullfunc,column_transition_func)
!:
        rts



bmp_column_draw:

        ldx #0

.for(var y=0;y<10;y++){

        lda cod_screen_d800+[y*$28],x
        sta COD_BMP_SCREEN_1+[y*$28],x
    //    sta COD_BMP_SCREEN_2+[y*$28],x

//        lda cod_screen_d800+$88+[y*$28],x
//        sta COD_BMP_SCREEN_1+$88+[y*$28],x
//        sta COD_BMP_SCREEN_2+$88+[y*$28],x

        lda cod_screen_d800+$3e8+[y*$28],x
        sta $d800+[y*$28],x
        //lda cod_screen_d800+$3e8+$88+[y*$28],x
        //sta $d800+$88+[y*$28],x
}

        inc bmp_column_draw+1
        lda bmp_column_draw+1
        cmp #$5
        bne !+
        inc premain+1
!:

        cmp #$28
        bne !+
        :set_addr(nullfunc,bmp_transition_func)

        lda #STA_ABS
        sta sp_op0

        lda #LDA_ABS
        sta sp_op1

        lda #1
        sta can_blink_col+1

        lda #0
        sta blgo+1
!:
        rts
