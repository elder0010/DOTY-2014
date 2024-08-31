//Scene Debug variables
.const debug_music = false
.const skip_intro = false

//Constants
.const border_stabilizer_irq_line = $0
.const stabilizer_irq_line = $2c

.const reset_a = $90
.const reset_x = $91
.const reset_y = $92

.const INTRO_SCREEN = $6400
.const SCREEN_1 = $4400
.const SCREEN_2 = $4800
.const intro_sprite = $6c40

.const COD_BMP_SCREEN_1 = $0400
.const COD_BMP_SCREEN_2 = $0800
.const horizontal_sprites_transition_location = $0c00

.const LOW_SCREEN_1 = $a400
.const LOW_SCREEN_2 = $a800
.print "Low screen 1 $"+ toHexString(LOW_SCREEN_1)
.print "Low screen 2 $"+ toHexString(LOW_SCREEN_2)

//Base charset
.const charset_1 = $5000
//Fade charsets
.const charset_1_0 = $5800
.const charset_1_1 = $6000
.const charset_1_2 = $6800
.const charset_1_3 = $7800

.print "Charset 0: $"+toHexString(charset_1)
.print "Charset 1: $"+toHexString(charset_1_0)
.print "Charset 2: $"+toHexString(charset_1_1)
.print "Charset 3: $"+toHexString(charset_1_2)
.print "Charset 4: $"+toHexString(charset_1_3)

.const bmp_screen_sprites = $3000-$40
.const sprites_1 = bmp_screen_sprites+$4000
.const sprites_horizontal = $b140

.const INTRO_SCREEN_d018 = [[[INTRO_SCREEN & $3fff] / $0400] << 4] + [[[charset_1 & $3fff] / $0800] << 1]
.const SCREEN_1_d018 = [[[SCREEN_1 & $3fff] / $0400] << 4] + [[[charset_1 & $3fff] / $0800] << 1]
.const LOW_SCREEN_1_d018 = [[[LOW_SCREEN_1 & $3fff] / $0400] << 4] + [[[charset_1 & $3fff] / $0800] << 1]
.const COD_SCREEN_d018 = [[[COD_BMP_SCREEN_1 & $3fff] / $0400] << 4] + [[[COD_BMP_SCREEN_1 & $3fff] / $0800] << 1] | 8

//Text screen sprite position
.const sprite_y_start = $35
.const top_sprites_y = $13
.const bottom_sprites_y = $02
.const right_column_x = $56
.const left_column_x = $e4
.const horizontal_sprites_x =  $29 //$6d

.const BG_COLOUR = RED
.const BORDER_COLOUR = RED
.const HORIZONTAL_SPRITES_COLOUR = YELLOW
.const VERTICAL_SPRITES_COLOUR = YELLOW
.const MAIN_TEXT_COLOUR = LIGHT_GRAY

//Timing stuff
.const delay_pre_dqtr_fade = $58  //attesa fade DQTY
.const delay_post_dqtr_fade = $37 //dopo il fade DQTY prima di partire con l'outro

//Zero page stuff
//intro
.const STATE_DISABLED = 0
.const STATE_READY = 1
.const STATE_FADING = 2
.const STATE_MOVING = 3
.const STATE_WAITING = 4
.const STATE_ARRIVED = 5

.const sprite_select = $21
.const block_sequence = $22
.const draw_busy = $23

//no borders scene
.const addr_1 = $20 //$11
.const addr_2 = $22

.const col_ct = $22
.const row_ct = $23
.const column = $24
.const colour = $25
.const tmp = $26
.const c_start = $27
.const col_pt = $28

.const can_go_next_page = $29
.const screen_busy = $2a
.const page_pt = $4
.const page_flip = $2c
.const bank = $2d
.const screen = $2e
.const transition_step = $2f
.const transition_running = $30
