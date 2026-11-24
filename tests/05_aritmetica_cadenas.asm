# Cubre y amplía:
# add/sub con operandos positivos y negativos; and/or con bits en los
# 16 bits altos; addi con inmediato negativo; addiu mediante li y addu
# mediante move; escritura en $zero; operaciones encadenadas con patrones
# de 32 bits y comprobación de resultados intermedios.

.text
.globl main
main:
    # Operaciones con valores completos de 32 bits.
    li    $t0, 0x12345678
    li    $t1, 0x01020304
    add   $s0, $t0, $t1       # 1336597C (dos positivos)
    sub   $s1, $t0, $t1       # 11325374 (dos positivos)

    li    $t6, -12345
    add   $t5, $t6, $t1      # 0101D2CB (un operando negativo)
    sub   $t7, $t0, $t6      # 123486B1 (resta de un negativo)
    addi  $s2, $t0, -32768   # 1233D678

    # li con constante dentro del rango de 16 bits: MARS genera addiu.
    li    $s3, -32768         # FFFF8000

    # AND y OR con patrones que activan bits altos.
    li    $t2, 0xF0F0AA55
    li    $t3, 0x0FF055AA
    and   $s4, $t2, $t3       # 00F00000
    or    $s5, $t2, $t3       # FFF0FFFF

    # addu no debe provocar excepcion por desbordamiento.
    addu  $s6, $t2, $t3       # 00E0FFFF (resultado modulo 2^32)

    # move se traduce a addu. La escritura en $zero debe ignorarse.
    move  $s7, $s6
    addi  $zero, $zero, 123
    addu  $t4, $zero, $zero   # 00000000

    move  $a0, $s0
    jal   print_hex
    move  $a0, $s1
    jal   print_hex
    move  $a0, $t5
    jal   print_hex
    move  $a0, $t7
    jal   print_hex
    move  $a0, $s2
    jal   print_hex
    move  $a0, $s3
    jal   print_hex
    move  $a0, $s4
    jal   print_hex
    move  $a0, $s5
    jal   print_hex
    move  $a0, $s6
    jal   print_hex
    move  $a0, $s7
    jal   print_hex
    move  $a0, $t4
    jal   print_hex

    addi  $v0, $zero, 10
    syscall

# Entrada: $a0 = palabra. Imprime 8 digitos hexadecimales y newline.
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
