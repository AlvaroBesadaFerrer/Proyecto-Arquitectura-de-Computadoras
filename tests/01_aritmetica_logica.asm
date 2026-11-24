# Cubre: add y sub con operandos positivos y con al menos un negativo;
# and y or con operandos que tienen unos en los 16 bits altos;
# addi con inmediato negativo; addiu mediante li; addu mediante move;
# escritura en $zero sin efecto.

.text
.globl main
main:
    # add: operandos positivos y, despues, un operando negativo.
    li    $t0, 1000
    li    $t1, 234
    add   $s0, $t0, $t1       # 000004D2 = 1234

    li    $t2, -500
    add   $s1, $t2, $t1       # FFFFFEF6 = -266

    # sub: operandos positivos y, despues, un operando negativo.
    sub   $s2, $t0, $t1       # 000002FE = 766
    sub   $s3, $t2, $t1       # FFFFFD22 = -734

    # AND y OR con bits altos activos en ambos operandos.
    lui   $t3, 0xF0F0
    ori   $t3, $t3, 0x00FF    # F0F000FF
    lui   $t4, 0x0FF0
    ori   $t4, $t4, 0xF00F    # 0FF0F00F
    and   $s4, $t3, $t4      # 00F0000F
    or    $s5, $t3, $t4      # FFF0F0FF

    # addi con inmediato negativo.
    addi  $s6, $t0, -123      # 0000036D = 877

    # li con constante de 16 bits: MARS debe generar addiu.
    # move: MARS debe generar addu.
    li    $s7, -123
    move  $t5, $s7

    # Una escritura en $zero debe descartarse.
    addi  $zero, $zero, 7
    move  $t6, $zero          # debe seguir siendo 00000000

    # Imprime los resultados en el mismo orden en que se describen arriba.
    move  $a0, $s0
    jal   print_hex
    move  $a0, $s1
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
    move  $a0, $t5
    jal   print_hex
    move  $a0, $t6
    jal   print_hex

    addi  $v0, $zero, 10
    syscall

# Entrada: $a0 = palabra que se quiere imprimir.
# Imprime ocho digitos hexadecimales en mayusculas y un salto de linea.
# Es una rutina hoja: no modifica $s0-$s7 ni vuelve a llamar a otra rutina.
print_hex:
    move  $t0, $a0
    addi  $t3, $zero, 8
ph_loop:
    srl   $t1, $t0, 28
    sll   $t0, $t0, 4
    slti  $t2, $t1, 10
    bne   $t2, $zero, ph_digit
    addi  $t1, $t1, 55       # 10..15 -> 'A'..'F'
    j     ph_emit
ph_digit:
    addi  $t1, $t1, 48       # 0..9 -> '0'..'9'
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
