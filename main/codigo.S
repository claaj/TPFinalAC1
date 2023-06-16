#define __SFR_OFFSET 0
#include "avr/io.h"

; Las funciones que se llaman desde el .ino se deben declarar como globales
; N° DE REGISTRO - INFORMACION ALMACENADA
; 1O               Distancia derecha.
; 11               Distancia izquierda.
; 15               Indica si hay que ejecutar elegir_lado.
; 17               Posicion servo.
; 19		           Motor1
; 20		           Motor2
; 21	             Distancia ultrasonico.
; 22               16 constante.

.global setup_asm
.global girar_derecha
.global avanzar
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
  ldi r17, 90
  ldi r22, 16
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
  clr r15
  cpi r21, 16
  brlo eludir
  jmp fin_check_dist
eludir:
  inc r15
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

girar_izquierda:
  ldi r19, 0
  ldi r20, 150
RET

girar_derecha:
  ldi r19, 150
  ldi r20, 0
RET

avanzar:
  ldi r19, 150
  ldi r20, 150
RET

frenar:
  ldi r19, 0
  ldi r20, 0
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