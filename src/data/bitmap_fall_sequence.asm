.var list_y = List().add(0,12,7,10,2,7,11,3,8,11,8,3,11,11,11,0,5,6,7,3,9,3,4,2,8,2,7,6,8,1,9,6,2,6,7,10,12,3,10,9,0,0,0,9,4,3,0,10,10,2,2,9,8,1,8,1,7,6,12,12,0,12,6,2,1,9,4,5,7,7,8,11,12,2,10,10,3,0,8,3,6,1,10,7,11,12,10,9,2,8,9,2,0,3,6,6,4,3,5,11,10,7,4,12,11,12,11,0,10,1,5,6,11,6,12,8,11,4,7,11,6,9,3,4,7,1,6,1,4,2,10,6,0,4,9,8,5,5,11,0,11,0,7,5,2,4,6,4,5,5,10,2,2,8,5,4,4,4,8,10,3,1,5,12,12,9,12,6,9,9,2,7,5,1,7,7,7,12,0,4,3,9,12,6,6,11,11,12,0,3,0,3,2,1,3,0,4,7,5,1,3,1,0,8,2,7,7,3,8,9,10,6,5,2,5,8,1,9,9,11,0,9,10,12,8,6,5,3,4,5,1,5,10,3,2,10,11,9,4,1,4,8,1,12,1,8,10,5,12,12,9,10,1,4,8,5,2,0,1,11)
.var list_x = List().add(11,18,7,13,15,15,11,10,6,12,18,11,8,0,10,18,0,9,9,16,12,9,0,1,2,10,11,3,17,3,18,4,14,8,18,7,2,8,14,13,17,5,3,0,9,0,1,0,1,5,9,19,4,8,11,15,5,15,12,13,14,3,11,6,5,5,4,7,4,10,7,15,15,16,15,4,19,9,14,6,2,17,5,13,13,7,8,4,2,8,7,7,10,17,12,7,8,14,8,5,11,0,6,11,17,17,9,2,16,4,3,14,2,17,16,16,7,17,14,6,19,17,3,13,2,11,5,14,1,19,6,1,0,11,1,12,12,1,16,4,18,6,19,5,12,18,6,2,17,6,10,3,13,10,19,19,16,3,0,12,13,0,9,1,14,16,9,13,8,10,0,17,18,1,12,1,16,4,19,10,5,6,0,10,0,3,19,5,13,4,7,2,11,10,7,12,5,6,10,12,12,2,8,19,8,8,3,18,5,14,9,18,13,18,14,1,16,3,9,4,15,15,18,19,3,16,15,1,7,2,7,11,3,15,4,2,1,2,12,13,14,13,9,8,6,9,17,4,10,6,11,19,18,15,15,16,17,16,19,14)

.align list_x.size()
block_sequence_x:
.for(var x=0;x<list_x.size();x++){
    .byte list_x.get(x)
}

.align list_x.size()
block_sequence_y:
.for(var x=0;x<list_y.size();x++){
    .byte list_y.get(x)
}

.align list_x.size()
block_direction:
.for(var x=0;x<list_x.size();x++){
    .var c=list_x.get(x)
    .if(c>=10){
        .byte 1
    }
    .if(c<10){
        .byte 0
    }
}