# Cubre y amplía:
# lw/sw con desplazamientos positivo y negativo; lb/lbu sobre bytes con
# bit 7=1 en offsets diferentes; sb en offsets 0,1,2,3 de la misma
# palabra, verificando con lw el contenido completo tras cada escritura.
# Combina lecturas, escrituras de palabra y escrituras parciales.

.data
.align 2
block:      .word 0x01234567, 0x89ABCDEF, 0x10203040, 0x55667788
byte_cell:  .word 0x80FF7F01

.text
.globl main
main:
    # Puntero a la segunda palabra para disponer de offsets + y -.
    la    $s0, block
    addi  $s0, $s0, 4

    lw    $a0, -4($s0)       # 01234567
    jal   print_hex

    li    $t0, 0xA1B2C3D4
    sw    $t0, 8($s0)        # offset positivo: cuarta palabra
    lw    $a0, 8($s0)        # A1B2C3D4
    jal   print_hex

    li    $t0, 0x0BADF00D
    sw    $t0, -4($s0)       # offset negativo: primera palabra
    lw    $a0, -4($s0)       # 0BADF00D
    jal   print_hex

    # Bytes FF y 80: deben extender signo en lb y ceros en lbu.
    la    $s1, byte_cell
    lb    $a0, 2($s1)        # FFFFFFFF
    jal   print_hex
    lbu   $a0, 2($s1)        # 000000FF
    jal   print_hex
    lb    $a0, 3($s1)        # FFFFFF80
    jal   print_hex
    lbu   $a0, 3($s1)        # 00000080
    jal   print_hex

    # Escribe cada carril; lw comprueba que los otros tres se conservan.
    addi  $t1, $zero, 0xAA
    sb    $t1, 0($s1)
    lw    $a0, 0($s1)        # 80FF7FAA
    jal   print_hex

    addi  $t1, $zero, 0xBB
    sb    $t1, 1($s1)
    lw    $a0, 0($s1)        # 80FFBBAA
    jal   print_hex

    addi  $t1, $zero, 0xCC
    sb    $t1, 2($s1)
    lw    $a0, 0($s1)        # 80CCBBAA
    jal   print_hex

    addi  $t1, $zero, 0xDD
    sb    $t1, 3($s1)
    lw    $a0, 0($s1)        # DDCCBBAA
    jal   print_hex

    addi  $v0, $zero, 10
    syscall

print_hex:
    move  $t0, $a0
    addi  $t3, $zero, 8
ph_loop:
    srl   $t1, $t0, 28
    sll   $t0, $t0, 4
    slti  $t2, $t1, 10
    bne   $t2, $zero, ph_digit
    addi  $t1, $t1, 55
    j     ph_emit
ph_digit:
    addi  $t1, $t1, 48
ph_emit:
    move  $a0, $t1
    addi  $v0, $zero, 11
    syscall
    addi  $t3, $t3, -1
    bne   $t3, $zero, ph_loop
    addi  $a0, $zero, 10
    addi  $v0, $zero, 11
    syscall
    jr    $ra
