px_columns_src_lo:
.for (var x=0;x<=19;x++){
    .byte <pic+[x*16]
}

px_columns_src_hi:
.for (var x=0;x<=19;x++){
    .byte >pic+[x*16]
}

px_rows_src_lo:
.for (var y=0;y<=12;y++){
    .byte <[40*16*y]
}

px_rows_src_hi:
.for (var y=0;y<=12;y++){
    .byte >[40*16*y]
}
//Dest
px_columns_dst_lo:
.for (var x=0;x<=19;x++){
    .byte <$4000+[x*16]
}

px_columns_dst_hi:
.for (var x=0;x<=19;x++){
    .byte >$4000+[x*16]
}

px_rows_dst_lo:
.for (var y=0;y<=12;y++){
    .byte <[40*16*y]
}

px_rows_dst_hi:
.for (var y=0;y<=12;y++){
    .byte >[40*16*y]
}

.align 160
//--------------------------------------
//Colours
//--------------------------------------
//Source
colours_columns_src_lo:
.for (var x=0;x<=19;x++){
    .byte <pic+$1f40+[x*2]
}
colours_columns_src_hi:
.for (var x=0;x<=19;x++){
    .byte >pic+$1f40+[x*2]
}

colours_rows_src_lo:
.for (var y=0;y<=12;y++){
    .byte <[y*80]
}
colours_rows_src_hi:
.for (var y=0;y<=12;y++){
    .byte >[y*80]
}
//Dest
colours_columns_dst_lo:
.for (var x=0;x<=19;x++){
    .byte <INTRO_SCREEN+[x*2]
}
colours_columns_dst_hi:
.for (var x=0;x<=19;x++){
    .byte >INTRO_SCREEN+[x*2]
}

colours_rows_dst_lo:
.for (var y=0;y<=12;y++){
    .byte <[y*80]
}
colours_rows_dst_hi:
.for (var y=0;y<=12;y++){
    .byte >[y*80]
}

.align 160
//--------------------------------------
//$d800 Colour Ram
//--------------------------------------
//Source
d8_columns_src_lo:
.for (var x=0;x<=19;x++){
    .byte <pic+$2328+[x*2]
}
d8_columns_src_hi:
.for (var x=0;x<=19;x++){
    .byte >pic+$2328+[x*2]
}

d8_rows_src_lo:
.for (var y=0;y<=12;y++){
    .byte <[y*80]
}
d8_rows_src_hi:
.for (var y=0;y<=12;y++){
    .byte >[y*80]
}
//Dest
d8_columns_dst_lo:
.for (var x=0;x<=19;x++){
    .byte <$d800+[x*2]
}
d8_columns_dst_hi:
.for (var x=0;x<=19;x++){
    .byte >$d800+[x*2]
}

d8_rows_dst_lo:
.for (var y=0;y<=12;y++){
    .byte <[y*80]
}
d8_rows_dst_hi:
.for (var y=0;y<=12;y++){
    .byte >[y*80]
}
