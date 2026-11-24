# Cubre: slt y slti con resultado 1 y 0, incluyendo comparaciones con
# un negativo donde signo y sin signo discrepan; sll y srl con shamt=0
# y shamt distinto de 0; srl sobre un valor negativo; andi y ori con
# bit 15 del inmediato a 1 (extension con ceros); lui con bit 15 a 1.

.text
.globl main
main:
    li    $t0, -1
    li    $t1, 1

    # -1 < 1 es cierto con signo (pero falso sin signo).
    slt   $s0, $t0, $t1      # 00000001
    # 1 < -1 es falso con signo (pero cierto sin signo).
    slt   $s1, $t1, $t0      # 00000000
    slti  $s2, $t0, 1        # 00000001
    slti  $s3, $t1, -1       # 00000000

    move  $a0, $s0
    jal   print_hex
    move  $a0, $s1
    jal   print_hex
    move  $a0, $s2
    jal   print_hex
    move  $a0, $s3
    jal   print_hex

    # El bit 15 del inmediato vale 1.
    lui   $s4, 0x8001        # 80010000
    li    $t2, -1
    andi  $s5, $t2, 0x8001   # 00008001, no FFFF8001
    li    $t3, 0x12340000
    ori   $s6, $t3, 0x8001   # 12348001

    move  $a0, $s4
    jal   print_hex
    move  $a0, $s5
    jal   print_hex
    move  $a0, $s6
    jal   print_hex

    # El operando es negativo: 0x81234567.
    li    $t4, 0x81234567
    sll   $s7, $t4, 0        # shamt=0: 81234567
    move  $a0, $s7
    jal   print_hex

    sll   $a0, $t4, 4        # shamt!=0: 12345670
    jal   print_hex
    srl   $a0, $t4, 0        # shamt=0: 81234567
    jal   print_hex
    srl   $a0, $t4, 4        # logico: 08123456
    jal   print_hex

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
