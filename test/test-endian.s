# Run this, and it should tell you whether your SPIM architecture is
# little-endian or big-endian


.data

HELLO: .asciiz "Hello There\n"
BYE: .asciiz "Bye There\n"


## unencrypted
TESTPHRASE: .word 0x53454854, 0x48544045, 0x59545249, 0x47494540, 0x54405448, 0x544e4557, 0x45534059, 0x404e4556, 0x44555453, 0x53544e45, 0x56414840, 0x52434045, 0x454b4341, 0x554f4044, 0x4f434052, 0x40444544, 0x5353454d, 0x40454741, 0x48414f44 


.text
main: 

      la $a0, HELLO
        li $v0, 4
        syscall

la $a0, TESTPHRASE

PrintIt:
        li $v0, 4
        syscall


      la $a0, BYE
        li $v0, 4
        syscall
jr $ra 
