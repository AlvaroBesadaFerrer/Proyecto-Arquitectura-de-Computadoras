# Test 06: reset y NOP.
# Comprueba al arrancar tras RESET:
# - $ra=0 y una guarda en la primera instruccion que detecta, por ejemplo,
#   un arranque desplazado a 0x00000004.
# - $gp = 0x00001800 y $sp = 0x00003FFC.
# - Todos los registros generales distintos de $gp/$sp empiezan en 0
#   (incluidos $zero y $ra; $s0 se comprueba mediante la marca inicial).
# - Varios NOP consecutivos no alteran registros ni impiden continuar.
# Ejecutar con run_tests.py, que aplica RESET antes de cada programa.

.text
.globl main
main:
    # Esta debe ser la primera instruccion en 0x00000000.
    # Si PC=0 y $ra=0, salta sobre la instruccion que pone la marca.
    # Si se empieza en 0x00000004, o $ra no se ha reiniciado a 0,
    # la marca se activa y la prueba falla.
    beq   $ra, $zero, pc_inicial_correcto
    addi  $s0, $zero, 1
pc_inicial_correcto:
    bne   $s0, $zero, fail

    # Comprobar que los otros registros generales empiezan en cero.
    # $ra y $s0 ya se han comprobado arriba. $zero se comprueba tambien
    # tras intentar escribir en el.
    bne   $at, $zero, fail
    bne   $v0, $zero, fail
    bne   $v1, $zero, fail
    bne   $a0, $zero, fail
    bne   $a1, $zero, fail
    bne   $a2, $zero, fail
    bne   $a3, $zero, fail
    bne   $t0, $zero, fail
    bne   $t1, $zero, fail
    bne   $t2, $zero, fail
    bne   $t3, $zero, fail
    bne   $t4, $zero, fail
    bne   $t5, $zero, fail
    bne   $t6, $zero, fail
    bne   $t7, $zero, fail
    bne   $s1, $zero, fail
    bne   $s2, $zero, fail
    bne   $s3, $zero, fail
    bne   $s4, $zero, fail
    bne   $s5, $zero, fail
    bne   $s6, $zero, fail
    bne   $s7, $zero, fail
    bne   $t8, $zero, fail
    bne   $t9, $zero, fail
    bne   $k0, $zero, fail
    bne   $k1, $zero, fail
    bne   $fp, $zero, fail

    # Comprobar los valores iniciales especificos de $gp y $sp.
    addi  $t0, $zero, 0x1800
    bne   $gp, $t0, fail
    addi  $t0, $zero, 0x3FFC
    bne   $sp, $t0, fail

    # $zero debe ignorar las escrituras y continuar valiendo cero.
    addi  $zero, $zero, 123
    bne   $zero, $zero, fail

    # Preparar registros con patrones reconocibles.
    lui   $s0, 0x1234
    ori   $s0, $s0, 0x5678       # 12345678
    lui   $s1, 0x89AB
    ori   $s1, $s1, 0xCDEF       # 89ABCDEF
    lui   $t4, 0x0BAD
    ori   $t4, $t4, 0xF00D       # 0BADF00D

    # NOP equivale a sll $zero, $zero, 0. Se ejecutan varios seguidos.
    nop
    nop
    nop
    nop

    # Verificar que los NOP no han modificado los registros centinela,
    # y que $gp/$sp conservan sus valores.
    lui   $t0, 0x1234
    ori   $t0, $t0, 0x5678
    bne   $s0, $t0, fail
    lui   $t0, 0x89AB
    ori   $t0, $t0, 0xCDEF
    bne   $s1, $t0, fail
    lui   $t0, 0x0BAD
    ori   $t0, $t0, 0xF00D
    bne   $t4, $t0, fail
    addi  $t0, $zero, 0x1800
    bne   $gp, $t0, fail
    addi  $t0, $zero, 0x3FFC
    bne   $sp, $t0, fail

    # Salida calculada: GP, SP, los tres centinelas y marca de exito.
    addi  $s2, $zero, 1
    move  $a0, $gp
    jal   print_hex
    move  $a0, $sp
    jal   print_hex
    move  $a0, $s0
    jal   print_hex
    move  $a0, $s1
    jal   print_hex
    move  $a0, $t4
    jal   print_hex
    move  $a0, $s2
    jal   print_hex

    addi  $v0, $zero, 10
    syscall

fail:
    # Cualquier estado inicial incorrecto o NOP con efectos deja una
    # salida distinta de la esperada.
    addi  $a0, $zero, -1
    jal   print_hex
    addi  $v0, $zero, 10
    syscall

# Entrada: $a0 = palabra. Imprime ocho digitos hexadecimales y newline.
# No modifica $s0-$s7, $gp ni $sp.
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
