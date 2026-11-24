# Cubre: lw y sw con desplazamiento positivo y negativo; lb y lbu sobre
# bytes con bit 7=1 en posiciones distintas (offset 2 y 3); sb en las
# cuatro posiciones 0,1,2,3 de una misma palabra, comprobando cada
# resultado con lw para verificar que los otros bytes se conservan.

.data
.align 2
words:       .word 0x11111111, 0x22222222, 0x33333333
byte_word:   .word 0x11223344
signed_word: .word 0x80FF7F01

.text
.globl main
main:
    # La base apunta a la palabra central de words.
    # Se escriben y leen las palabras anterior y siguiente.
    la    $s0, words
    addi  $s1, $s0, 4
    li    $t0, 0xA1B2C3D4
    sw    $t0, 4($s1)        # desplazamiento positivo
    li    $t1, 0x0BADF00D
    sw    $t1, -4($s1)       # desplazamiento negativo

    lw    $a0, 4($s1)
    jal   print_hex          # A1B2C3D4
    lw    $a0, -4($s1)
    jal   print_hex          # 0BADF00D

    # sb en los cuatro carriles de la misma palabra.
    # Despues de cada sb, lw comprueba toda la palabra.
    la    $s4, byte_word

    addi  $t2, $zero, 0xAA
    sb    $t2, 0($s4)
    lw    $a0, 0($s4)        # 112233AA
    jal   print_hex

    addi  $t2, $zero, 0xBB
    sb    $t2, 1($s4)
    lw    $a0, 0($s4)        # 1122BBAA
    jal   print_hex

    addi  $t2, $zero, 0xCC
    sb    $t2, 2($s4)
    lw    $a0, 0($s4)        # 11CCBBAA
    jal   print_hex

    addi  $t2, $zero, 0xDD
    sb    $t2, 3($s4)
    lw    $a0, 0($s4)        # DDCCBBAA
    jal   print_hex

    # Los bytes 2 y 3 de 0x80FF7F01 son FF y 80.
    # lb debe extender el signo; lbu debe extender con ceros.
    la    $s5, signed_word
    lb    $a0, 2($s5)
    jal   print_hex          # FFFFFFFF
    lbu   $a0, 2($s5)
    jal   print_hex          # 000000FF
    lb    $a0, 3($s5)
    jal   print_hex          # FFFFFF80
    lbu   $a0, 3($s5)
    jal   print_hex          # 00000080

    addi  $v0, $zero, 10
    syscall

# Entrada: $a0 = palabra que se quiere imprimir.
# Imprime ocho digitos hexadecimales en mayusculas y un salto de linea.
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
