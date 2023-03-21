    .data

EncryptedPhrase: .word 0x5f7fb06, 0xfb06f2f8, 0xc0704fb, 0xf9fbf7f3, 0x6f306fb, 0x700f809, 0xf805f30b, 0xf300f808, 0xf7080706, 0x60700f8, 0x8f3faf3, 0x4f5f2f7, 0xf7fdf5f4, 0x801f2f7, 0x1f5f304, 0xf2f6f7f7, 0x605f7ff, 0xf2f7f9f3, 0xfaf401f7, 0x0

DecryptionSpace: .space 400 # 400 bytes of space, more than enough...

EndMsg:         .asciiz "\n\n"

    .text
main:
        li      $s0, 1
        li      $s1, 255

        la      $a0, EncryptedPhrase
        la      $a1, DecryptionSpace
        move    $a2, $s0                # Key is initially 01010101
        sll     $a2, $a2, 8
        addu    $a2, $a2, $s0
        sll     $a2, $a2, 8
        addu    $a2, $a2, $s0
        sll     $a2, $a2, 8
        addu    $a2, $a2, $s0
MAINLOOP:
        beq     $s0, $s1, MAINRETURN    # Exit once key is FFFFFFFF
        jal     AddAndVerify
        beq     $v0, 1,   PRINTMSG
        j       ENDPRINT
PRINTMSG:
        addi    $sp, $sp, -4
        sw      $a0, 0($sp)
        la      $a0, DecryptionSpace
        li      $v0, 4
        syscall
        la      $a0, EndMsg
        syscall
        lw      $a0, 0($sp)
        addi    $sp, $sp, 4
ENDPRINT:
        addi    $s0, 1
        move    $a2 $s0
        sll     $a2, $a2, 8
        addu    $a2, $a2, $s0
        sll     $a2, $a2, 8
        addu    $a2, $a2, $s0
        sll     $a2, $a2, 8
        addu    $a2, $a2, $s0
        j       MAINLOOP
MAINRETURN:
        li $v0, 10
        syscall

WordDecrypt:
        li      $v1, 0
        addu    $v0, $a0, $a1
        addu    $v0, $v0, $a2
        bgeu    $v0, $a1, NOCARRY
        li      $v1, 1
NOCARRY:
        jr      $ra

IsCandidate:
        li      $v0, 1                  # Result is initially set to true
        li      $t0, 0                  # Counter to track number of bytes read
LOOP:
        andi    $t1, $a0, 255
        beq     $t0, 4,   RETURN        # Exit after reading 4 bytes
        bltu    $t1, 64,  ISOUTOFRANGE
        bgtu    $t1, 90,  ISOUTOFRANGE
        j       ENDIF
ISOUTOFRANGE:
        li      $v0, 0                  # Set flag to false
ENDIF:
        srl     $a0, $a0, 8
        addi    $t0, $t0, 1
        j       LOOP
RETURN:
        jr      $ra

AddAndVerify:
        lw      $t0, 0($a0)             # Read word into $t0 to check base case
        beq     $t0, 0,    BASECASE
        j       ENDBASECASE
BASECASE:
        sw      $zero, 0($a1)
        li      $v0, 1                  # 0 word is valid
        li      $v1, 0                  # No carry
        jr      $ra
ENDBASECASE:
        addi    $sp, $sp, -12
        sw      $a0, 8($sp)
        sw      $a1, 4($sp)
        sw      $ra, 0($sp)
        addi    $a0, $a0, 4             # Increment encrypted word address
        addi    $a1, $a1, 4             # Increment decrypted word address
        jal     AddAndVerify
        lw      $a0, 8($sp)
        lw      $a1, 4($sp)
        lw      $ra, 0($sp)
        addi    $sp, $sp, 12
        beq     $v0, 1, ISVALIDSUFFIX
        j       NOTVALIDSUFFIX
ISVALIDSUFFIX:
        addi    $sp, $sp, -16           # Make space for $a0-$a2 and $ra
        sw      $a0, 12($sp)
        sw      $a1, 8($sp)
        sw      $a2, 4($sp)
        sw      $ra, 0($sp)
        lw      $a0, 0($a0)             # Read word
        move    $a1, $a2                # Copy key word to $a1
        move    $a2, $v1                # Copy previous carry to $a2
        jal     WordDecrypt
        move    $a0, $v0                # Copy WordDecrypt result to $a0
        addi    $sp, $sp, -4
        sw      $a0, 0($sp)             # Save decrypted word
        jal     IsCandidate
        lw      $a0, 0($sp)
        addi    $sp, $sp, 4
        lw      $a1, 8($sp)
        sw      $a0, 0($a1)             # Write decrypted word to memory

        lw      $a0, 12($sp)
        lw      $a2, 4($sp)
        lw      $ra, 0($sp)
        addi    $sp, $sp, 16
NOTVALIDSUFFIX:
        jr      $ra