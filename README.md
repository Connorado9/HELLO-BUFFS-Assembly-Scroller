# HELLO_BUFFS_Assembly
Written in NIOS II Assembly and run on the DE10-lite board from Intel, this program makes use of timer interrupts, rather than a delay loop, to scroll the message HELLO BUFFS across four 7-segment displays. As an additional requirement, when KEY1 is pressed, the message scrolls slower until a minimum speed is reached after 3 presses. When KEY0 is pressed, the scroll rate increases to a maximum of three settings higher than the default. 
