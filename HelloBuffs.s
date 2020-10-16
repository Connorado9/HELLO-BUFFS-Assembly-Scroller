.data
DISPCOUNT: 
	.word 0
DISPOUT:
	.word 0b00000000
SPEED:
	.word 3
	# 0 is slowest scroll speed, 3 is default scroll, 6 is fastest
TIME:
	.word 0b1011010101000

.text
	.equ	HEX,		0xFF200020
	.equ	H,			0b01110110 
    .equ	E, 			0b01111001
    .equ	l,			0b00110000
	.equ	O,			0b00111111
	.equ	B,			0b01111111
	.equ	U,			0b00111110
	.equ	f,			0b01110001
	.equ	S,			0b01101101
	.equ	dash,		0b01000000
	.equ	blank,		0b00000000
	.equ	patternA,	0b01001001
	.equ	patternB,	0b00110110
	.equ	patternC,	0b01111111

# Reset section
.section .reset, "ax"
    br      _start              # works for <=64MB, but more general to do
                                # movia     r2, _start
                                # jmp       r2

# Exception handler
.section .exceptions, "ax"
    subi    sp, sp, 24          # allocate stack
    stw     et, 0(sp)           # save all the registers we will use in our handler
    stw     r4, 4(sp)
    stw     r5, 8(sp)
    stw     r6, 12(sp)
	stw		r7, 16(sp)
	stw		r8, 20(sp)

    rdctl   et, ipending        # Check for external interrupt
    beq     et, r0, skip_dec	# if ipending is zero, we don't have to decrement exception address
    subi    ea, ea, 4           # decrement ea one instruction b/c external

  skip_dec:
  # figure out which interrupt happened
    movi    r5, 0b1 << 1        # IRQ1: buttons
    and     r5, et, r5
    bne     r5, r0, handle_button
    
    movi    r5, 0b1 << 0        # IRQ0: timer
    and     r5, et, r5
    bne     r5, r0, handle_timer

    br      leave_isr			# not button or timer

  handle_timer:
  # After a timer input, we must edit what's on the HEX displays
    movia   r4, 0xff202000      # timer0 MMIO
    movi    r5, 0b10            # RUN=1, TO=0
    sthio   r5, 0(r4)           # Clear timer interrupt

    movia   r4, DISPCOUNT
    ldw     r5, 0(r4)           # get DISPCOUNT into r5
	movi	r6, 29				# there are 30 orientations for pattern
	bleu	r5, r6,timer_display# if we haven't reached the pattern's end, continue as normal
	movi	r5, 0				# if we have reached end, reset counter to zero
  timer_display:
  # Here we chose the correct 4-letter combination for the displays
  	movia	r7, HEX				# Address of HEX 0-3
	movia   r4, DISPOUT
    ldw     r8, 0(r4)           # get DISPOUT into r8
	movi	r6, 0
	beq		r5, r6, pushH		# if the current count is 0, we push an H to HEX
	movi	r6, 1
	beq		r5, r6, pushE
	movi	r6, 2
	beq		r5, r6, pushL
	movi	r6, 3
	beq		r5, r6, pushL
	movi	r6, 4
	beq		r5, r6, pushO
	movi	r6, 5
	beq		r5, r6, pushBlank
	movi	r6, 6
	beq		r5, r6, pushB
	movi	r6, 7
	beq		r5, r6, pushU
	movi	r6, 8
	beq		r5, r6, pushF
	movi	r6, 9
	beq		r5, r6, pushF
	movi	r6, 10
	beq		r5, r6, pushS
	movi	r6, 11
	beq		r5, r6, pushDash
	movi	r6, 12
	beq		r5, r6, pushDash
	movi	r6, 13
	beq		r5, r6, pushDash
	movi	r6, 14
	beq		r5, r6, pushBlank
	movi	r6, 15
	beq		r5, r6, pushBlank
	movi	r6, 16
	beq		r5, r6, pushBlank
	movi	r6, 17
	beq		r5, r6, pushBlank
	movi	r6, 18
	beq		r5, r6, showPatternA
	movi	r6, 19
	beq		r5, r6, showPatternB
	movi	r6, 20
	beq		r5, r6, showPatternA
	movi	r6, 21
	beq		r5, r6, showPatternB
	movi	r6, 22
	beq		r5, r6, showPatternA
	movi	r6, 23
	beq		r5, r6, showPatternB
	movi	r6, 24
	beq		r5, r6, showPatternC
	movi	r6, 25
	beq		r5, r6, showBlank
	movi	r6, 26
	beq		r5, r6, showPatternC
	movi	r6, 27
	beq		r5, r6, showBlank
	movi	r6, 28
	beq		r5, r6, showPatternC
	movi	r6, 29
	beq		r5, r6, showBlank
  	
  # Here we output the 4-letter combination to the HEX displays
  pushH:
	ori		r8, r8, H			# Loading an H pattern on to the HEX output
	stwio	r8, 0(r7)			# displaying value at r8 to the HEX displays
	slli	r8, r8, 8			# shifting for next letter
	br 		leave_timer
  pushE:
  	ori		r8, r8, E
	stwio	r8, 0(r7)
	slli	r8, r8, 8
	br 		leave_timer
  pushL:
   	ori		r8, r8, l
	stwio	r8, 0(r7)
	slli	r8, r8, 8
	br 		leave_timer
  pushO:
  	ori		r8, r8, O
	stwio	r8, 0(r7)
	slli	r8, r8, 8
	br 		leave_timer
  pushBlank:
  	ori		r8, r8, blank
	stwio	r8, 0(r7)
	slli	r8, r8, 8
	br 		leave_timer
  pushB:
  	ori		r8, r8, B
	stwio	r8, 0(r7)
	slli	r8, r8, 8
	br 		leave_timer
  pushU:
  	ori		r8, r8, U
	stwio	r8, 0(r7)
	slli	r8, r8, 8
	br 		leave_timer
  pushF:
  	ori		r8, r8, f
	stwio	r8, 0(r7)
	slli	r8, r8, 8
	br 		leave_timer
  pushS:
  	ori		r8, r8, S
	stwio	r8, 0(r7)
	slli	r8, r8, 8
	br 		leave_timer
  pushDash:
  	ori		r8, r8, dash
	stwio	r8, 0(r7)
	slli	r8, r8, 8
	br 		leave_timer
  showPatternA:
  	slli	r8, r8, 8			# Fill r8 with 4 patternA's
  	ori		r8, r8, patternA		
	slli	r8, r8, 8
	ori		r8, r8, patternA
	slli	r8, r8, 8
	ori		r8, r8, patternA
	slli	r8, r8, 8
	ori		r8, r8, patternA
	stwio	r8, 0(r7)			# output to the HEX display
	br 		leave_timer
  showPatternB:
  	slli	r8, r8, 8			# Fill r8 with 4 patternB's
	ori		r8, r8, patternB		
	slli	r8, r8, 8
	ori		r8, r8, patternB
	slli	r8, r8, 8
	ori		r8, r8, patternB
	slli	r8, r8, 8
	ori		r8, r8, patternB
	stwio	r8, 0(r7)
	br 		leave_timer
  showPatternC:	
  	slli	r8, r8, 8			# Fill r8 with 4 patternB's
	ori		r8, r8, patternC		
	slli	r8, r8, 8
	ori		r8, r8, patternC
	slli	r8, r8, 8
	ori		r8, r8, patternC
	slli	r8, r8, 8
	ori		r8, r8, patternC
	stwio	r8, 0(r7)
	br 		leave_timer
  showBlank:
  	slli	r8, r8, 8			# Fill r8 with 4 blanks
	ori		r8, r8, blank			
	slli	r8, r8, 8
	ori		r8, r8, blank
	slli	r8, r8, 8
	ori		r8, r8, blank
	slli	r8, r8, 8
	ori		r8, r8, blank
	slli	r8, r8, 8
	stwio	r8, 0(r7)
  
  leave_timer:
  	addi    r5, r5, 1          	# add 1 to DISPCOUNT
  	movia   r4, DISPCOUNT
    stw     r5, 0(r4)           # store new DISPCOUNT
	movia   r4, DISPOUT
	stw		r8, 0(r4)			# restoring DISPOUT for the next interrupt
    br      leave_isr


  handle_button:
  # Figure out which push button was pressed and change the speed
    movia   r4, 0xFF200050      # button MMIO address
    ldwio   et, 12(r4)          # edge capture register

    movia   r5, SPEED
    ldw     r6, 0(r5)           # read current SPEED to r6
    
    beq     et, r0, done_btn    # if no button press
	movi	r5, 0b11
	beq		et, r5, done_btn	# if both buttons pressed at same time
	movi    r5, 0b10
    beq     et, r5, btn_1       # if btn1 pressed
	
  btn_0:                        # else, its btn0
  # Reconfiguring timer to increase scroll speed
  	addi    r6, r6, 1           # increment SPEED variable
	movi	r5, 6
	bgeu	r6, r5, btn0_over	# if we have gone over 6th speed, exit & dont edit speed
								# otherwise, continue as normal changing the speed
	# Reconfiguring timer
    movia   r16, 0xff202000		# Timer0 MMIO
	movia   r5, TIME
    ldw     r7, 0(r5)      		# fetching TIME into r7
	movi	r5, 3500
	slli	r5, r5, 10			# editing rate
	sub		r7, r7, r5			# decrease timer -> increase scroll speed

	mov		r8, r7				# we must transfer registers to save before shifting
    sthio   r8, 8(r16)      	# low counter start
    srli    r8, r8, 16      	# get high 16 bits
    sthio   r8, 12(r16)     	# high counter start
	movia	r5, TIME
	stw     r7, 0(r5)       	# store new TIME
    
    movi    r7, 0b111       	# START=1, CONT=1, ITO=1
    sthio   r7, 4(r16)
    movi    r7, 0b10        	# RUN=1
	br		btn0_exit
	
  btn0_over:
  	movi	r6, 6				# if we have gone over bounds (0-6), keep speed (r6) at 6
  btn0_exit:
    br      done_btn
	
  btn_1:
  # Reconfiguring timer to decrease scroll speed
	beq		r6, r0, btn1_under	# if we have reached 0, exit, not changing speed
								# otherwise, continue as normal
	subi    r6, r6, 1           # decrement SPEED variable
	# Reconfiguring timer
    movia   r16, 0xff202000		# Timer0 MMIO
	movia   r5, TIME
    ldw     r7, 0(r5)      		# fetching TIME into r7
	movi	r5, 3500
	slli	r5, r5, 10			# editing rate
	add		r7, r7, r5			# increase timer -> decrease scroll speed

	mov		r8, r7				# we must transfer registers to save before shifting
    sthio   r8, 8(r16)      	# low counter start
    srli    r8, r8, 16      	# get high 16 bits
    sthio   r8, 12(r16)     	# high counter start
	movia	r5, TIME
	stw     r7, 0(r5)       	# store new TIME
    
    movi    r7, 0b111       	# START=1, CONT=1, ITO=1
    sthio   r7, 4(r16)
    movi    r7, 0b10        	# RUN=1
	br		done_btn
  btn1_under:
  	movi	r6, 0				# if we have gone under bounds, keep r6 at 0
	
  done_btn:
    movia   r5, SPEED
    stw     r6, 0(r5)           # save new SPEED
    stwio   et, 12(r4)          # Clear the push button interrupt
                                # Note: despite documentation,
                                # you must write 1s to clear edgecapture reg
  
  leave_isr:
  # exception epilogue
  	ldw		r8, 20(sp)			# restore used registers
    ldw		r7, 16(sp)
	ldw     r6, 12(sp)          
    ldw     r5, 8(sp)
    ldw     r4, 4(sp)
    ldw     et, 0(sp)
    addi    sp, sp, 24          # deallocate stack
    eret
### end of exception handler ###
	
	
.global _start
_start:
    movia   sp, 0x04000000 - 4

    # 1.1 Configure peripheral (push buttons)
    movia   r16, 0xff200050 	# PUSH_BTN base addr
    movi    r7, 0b11        	# mask bits for push buttons
    stwio   r7, 8(r16)      	# interrupt mask register (push buttons)
    
    # 1.2 Configure timer0
    movia   r16, 0xff202000		# Timer0 MMIO
	movia   r6, TIME
    ldw     r7, 0(r6)      		# fetching TIME into r7
	slli	r7, r7, 12			# editing for speed
	mov		r8, r7				# we must transfer registers to save before shifting
    sthio   r8, 8(r16)      	# low counter start
    srli    r8, r8, 16      	# get high 16 bits
    sthio   r8, 12(r16)     	# high counter start
	stw     r7, 0(r6)       	# store new TIME
    
    movi    r7, 0b111       	# START=1, CONT=1, ITO=1
    sthio   r7, 4(r16)
    movi    r7, 0b10        	# RUN=1

    # 2 Enable peripherals to generate interrupts
    movi    r7, 0b1 << 1    	# IRQ #1 (Push buttons)
    ori     r7, r7, 0b1 << 0	# IRQ #0 (interval timer)
    wrctl   ienable, r7
    
    # 3 Turn on interrupts globally
    movi    r7, 1
    wrctl   status, r7
    
    movi    r4, 0
loop:
    addi    r4, r4, 1
    br      loop
	.end