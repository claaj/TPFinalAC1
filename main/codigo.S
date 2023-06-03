#define __SFR_OFFSET 0
#include "avr/io.h"

; Las funciones que se llaman desde el .ino se deben declarar como globales
; REGISTROS - INFORMACION ALMACENADA
; 10		Motor1
; 11		Motor2
; 16		Distancia ultrasonico.

.global servo
.global girar_derecha

servo:
	ldi r16, 180
RET

girar_derecha:
RET



