#define __SFR_OFFSET 0x00
#include "avr/io.h"

; Las funciones que se llaman desde el .ino se deben declarar como globales
; N° DE REGISTRO - INFORMACION ALMACENADA

; 07               Contador intentos esquive.
; 08               Constante distancia limite.
; 09               Distancia izquierda.
; 1O               Distancia derecha.
; 11               1 Constante.
; 12               2 Constante.
; 13               3 Constante.
; 14               4 Constante.
; 15               255 constante.
; 16               Indica si hay que ejecutar elegir_lado.
; 17               Posicion servo.
; 19               Motor1.
; 20               Motor2.
; 21               Distancia ultrasonico.

.global setup_asm
.global girar_derecha
.global avanzar
.global frenar
.global girar_izquierda
.global esquivar
.global check_distancia
.global servo_derecha 
.global servo_izquierda
.global servo_centro
.global delay_250
.global delay_500
.global delay_1000
.global elegir_lado

setup_asm:
  cbi DDRC, 0
  sbi DDRC, 1
  sbi DDRB, 4
  sbi DDRB, 5
  ldi r17, 90
  ldi r31, 255
  mov r15, r31
  
; Constantes para esquivar
  ldi r31, 0x04
  mov r14, r31
  mov r7, r31
  ldi r31, 0x03
  mov r13, r31
  ldi r31, 0x02
  mov r12, r31
  ldi r31, 0x01
  mov r11, r31
  ldi r31, 0x1D
  mov r8, r31
  RET

servo_derecha:
  ldi r17, 0
  RET

servo_izquierda:
  ldi r17, 180
  RET

servo_centro:
  ldi r17, 90
  RET

check_distancia:
  clr r16
  cp r21, r8
  brlo eludir
  jmp fin_check_dist
eludir:
  inc r16
fin_check_dist:
  RET

elegir_lado:
  cp r10, r9
  brlo izquierda
  rcall girar_derecha
  jmp fin_elegir_lado
izquierda:
  rcall girar_izquierda
fin_elegir_lado:
  RET

girar_izquierda:
  mov r19, r15
  clr r20
  sbi PORTB, 5
  cbi PORTB, 4
  RET

girar_derecha:
  clr r19
  mov r20, r15
  cbi PORTB, 5
  sbi PORTB, 4
  RET

avanzar:
  mov r19, r15
  mov r20, r15
  sbi PORTB, 5
  sbi PORTB, 4
  RET

frenar:
  clr r19
  clr r20
  cbi PORTB, 5
  cbi PORTB, 4
  RET

esquivar:
  cp r7, r14
  breq esquivar1
  cp r7, r13
  breq esquivar2
  cp r7, r12
  breq esquivar2
  cp r7, r11
  breq esquivar3
  jmp elegir_lado
esquivar1:
  cp r9, r8
  brsh esquivar_izquierda
  clr r7
  jmp elegir_lado
esquivar2:
  cp r10, r8
  brsh esquivar_derecha
  clr r7
  jmp elegir_lado
esquivar3:
  cp r9, r8
  brsh esquivar_final
  clr r7
  jmp elegir_lado
esquivar_izquierda:
  dec r7
  jmp girar_izquierda
esquivar_derecha:
  dec r7
  jmp girar_derecha
esquivar_final:
  clr r7
  jmp girar_izquierda
fin_esquivar:
  RET

delay_500:
  rcall delay_250
  rcall delay_250
  RET

delay_1000:
  rcall delay_500
  rcall delay_500
  RET

; Assembly code auto-generated
; by utility from Bret Mulvey
; Delay 4 000 000 cycles
; 250ms at 16.0 MHz
delay_250:
    ldi  r23, 21
    ldi  r24, 75
    ldi  r25, 191
L1: dec  r25
    brne L1
    dec  r24
    brne L1
    dec  r23
    brne L1
    nop
    RET