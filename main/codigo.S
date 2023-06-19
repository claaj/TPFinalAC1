#define __SFR_OFFSET 0x00
#include "avr/io.h"

; Las funciones que se llaman desde el .ino se deben declarar como globales
; N° DE REGISTRO - INFORMACION ALMACENADA
; 1O               Distancia derecha.
; 11               Distancia izquierda.
; 15               255 constante.
; 16               Indica si hay que ejecutar elegir_lado.
; 17               Posicion servo.
; 18               0 constante.
; 19               Motor1.
; 20               Motor2.
; 21               Distancia ultrasonico.

.global setup_asm
.global girar_derecha
.global avanzar
.global frenar
.global girar_izquierda
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
  ldi r18, 0
  ldi r31, 255
  mov r15, r31
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
  cpi r21, 0x1D
  brlo eludir
  jmp fin_check_dist
eludir:
  inc r16
fin_check_dist:
  RET

elegir_lado:
  cp r10, r11
  brlo izquierda
  rcall girar_derecha
  jmp fin_elegir_lado
izquierda:
  rcall girar_izquierda
fin_elegir_lado:
  RET

girar_izquierda:
  mov r19, r15
  mov r20, r18
  sbi PORTB, 5
  cbi PORTB, 4
  RET

girar_derecha:
  mov r19, r18
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
  mov r19, r18
  mov r20, r18
  cbi PORTB, 5
  cbi PORTB, 4
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