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

; Funciones para ser declaradas en codigo.h
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

setup_asm: ; Funcion que ira en el setup del .ino
  cbi DDRC, 0   ; Se setea el PIN A0 como entrada.
  sbi DDRC, 1   ; Se setea el PIN A1 como salida.
  sbi DDRB, 4   ; Se setea el pin 12 como salida, se usara este pin en la simulación para conectar un led.
  sbi DDRB, 5   ; Se setea el pin 13 como salida, se usara este pin en la simulación para conectar un led.
  ldi r17, 90   ; Posición inicial del servo en 90°.
  
; Constantes
; Se cargan en R31, porque soporta la carga de inmediatos.
; Luego se mueven al registro correspondiente.
  ldi r31, 200 ; Valor para constante de velocidad de motores.
  mov r15, r31 ; Se guarda en el R15 el valor 200.
  ldi r31, 0x04 ; Valor constante que será comparado en esquivar. 
  mov r14, r31 ; Se guarda en el R14 el valor 4.
  mov r7, r31  ; Contador de intentos a la hora de esquivar.
  ldi r31, 0x03 ; Valor constante que será comparado en esquivar. 
  mov r13, r31 ; Se guarda en el R13 el valor 3.
  ldi r31, 0x02 ; Valor constante que será comparado en esquivar. 
  mov r12, r31 ; Se guarda en el R12 el valor 2.
  ldi r31, 0x01 ; Valor constante que será comparado en esquivar. 
  mov r11, r31 ; Se guarda en el R11 el valor 1.
  ldi r31, 0x1E ; Valor constante que será comparado en esquivar y en check_distancia. 
  mov r8, r31 ; Se guarda en el R08 el valor 30.
  RET

servo_derecha: ; Función que setea el registro (R17) que controla el servo en la posición derecha 0 grados.
  clr r17 ; Se limpia el R17 dejandolo en 0.
  RET

servo_izquierda: ; Función que setea el registro (R17) que controla el servo en la posición izquierda 180 grados.
  ldi r17, 180 ; Se carga 180 en el registro 17.
  RET

servo_centro: ; Función que setea el registro (R17) que controla el servo en la posición central 90 grados.
  ldi r17, 90 ; Se carga 90  en el registro 17.
  RET

check_distancia: ; Función que verifica si el robot puede seguir avanzando en la dirección actual.
; Si la distancia (R21) es mayor a (R08) R16 se pone en 0, de lo contrario se pone en 1. 
  clr r16    ; Siempre se resetea el estado de R16.
  cp r21, r8 ; Se compara la medición de la distancia, con la distancia limite.
  brlo eludir ; Si es menor salta a eludir.
  jmp fin_check_dist ; Salta al final de la función.
eludir:
  inc r16 ; Se pone en un R16.
fin_check_dist:
  RET

elegir_lado: ; Función que teniendo las distancias del lado izquierdo y derecho, setea los motores para que giren hacia el lado
; donde hay mayor distancia.
  cp r10, r9  ; Se compara la distancia derecha (R10) con la distancia izquierda (R09).
  brlo izquierda ; Si la derecha es menor, salta a izquierda.
  rcall girar_derecha ; Ejecuta girar_derecha
  jmp fin_elegir_lado ; Salta a fin_elegir_lado.
izquierda:
  rcall girar_izquierda ; Ejecuta girar_izquierda.
fin_elegir_lado:
  RET

girar_izquierda: ; Función que setea las velocidades de los motores para doblar a la izquierda.
  mov r19, r15 ; Copia el valor constante al registro que controla el motor1.
  clr r20      ; Pone en 0 la velocidad del motor 2.
  sbi PORTB, 5 ; A modo de debug para la simulación prende el led izquierdo en el simulide.
  cbi PORTB, 4 ; A modo de debug para la simulación apaga el led derecho en el simulide
  RET

girar_derecha: ; Funcion que setea las velocidades de los motores para doblar a la derecha.
  clr r19 ; Pone la velocidad del motor 1 en 0.
  mov r20, r15 ; Copia el valor constante de la velocidad al registro que controla al motor 2.
  ldi r31, 54  ; Offset del motor derecho.
  add r20, r31 ; Suma el offset la velocidad del motor derecho.
  cbi PORTB, 5 ; A modo de debug para la simulación se apaga el led izquierdo en el simulide.
  sbi PORTB, 4 ; A modo de debug para la simulación se prende el led derecho en el simulide.
  RET

avanzar: ; Funcion que setea las velocidades de los motores para avanzar.
  mov r19, r15 ; Copia el valor constante de la velocidad a los registros que controlan las velocidades de los motores.
  mov r20, r15
  ldi r31, 54 ; Offset del motor derecho.
  add r20, r31 ; Suma el offset a la velocidad del motor derecho.
  sbi PORTB, 5 ; A modo de debug se prenden los dos leds en la simulacion del simulide.
  sbi PORTB, 4
  RET

frenar: ; Funcion que setea las velocidades de los motores para que estos frenar.
  clr r19 ; Se pone en 0 los dos registros que controlan la velocidad del los motores.
  clr r20
  cbi PORTB, 5 ; A modo de debug se apagan los leds en la simulacion del simulide.
  cbi PORTB, 4
  RET

esquivar: ; Funcion que controla los pasos para esquivar un objeto.
; Primero dobla a la izquierda, luego a la derecha dos veces y por ultimo a la izquierda de nuevo.
; Si en algun momento no se puede retormar el camino, se desactiva el esquive y de ahora en más va hacia el lado donde tenga más distancia.
; Para aprovechar el loop del arduino el registro (R07) con tiene el estado actual de las fases del esquive y en base al valor de ese registro se operara.
  cp r7, r14 ; Si el contador para esquivar esta en 4.
  breq esquivar1 ; Salta a esquivar1.
  cp r7, r13 ; Si el contador para esquivar esta en 3.
  breq esquivar2 ; Salta a esquivar2.
  cp r7, r12 ;  Si el contador para esquivar esta en 2.
  breq esquivar2 ; Salta esquivar2.
  cp r7, r11 ; Si el contador para esquivar es 1.
  breq esquivar3 ; Salta a esquivar3.
  jmp elegir_lado; Si no se cumple ninguna de las anteriores salta a elegir_lado.
esquivar1: ; Se implementa la primera parte 
  cp r9, r8 ; Si hay espacio para ir hacia la izquierda
  brsh esquivar_izquierda ; Esquiva hacia la izquierda.
  clr r7 ; De lo contario, se pone en 0 para cancelar el esquive. 
  jmp elegir_lado; Y salta a elegir_lado.
esquivar2: ; Segunda parte y 3 parte.
  cp r10, r8 ; Verifica que haya lugar para ir a la derecha.
  brsh esquivar_derecha ; Esquiva a la derecha si hay lugar para hacerlo.
  clr r7 ; En caso de no poder, se pone en 0 y se cancela el esquive.
  jmp elegir_lado ; Y salta a elegir lado.
esquivar3: ; Ultima parte del esquive
  cp r9, r8 ; Verifica si hay espacio para doblar a la izquierda.
  brsh esquivar_final ; Si hay salta a esquivar final.
  clr r7 ; En caso de no poder pone en 0 y se cancela el esquive.
  jmp elegir_lado ; Salta a elegir lado.
esquivar_izquierda:
  dec r7 ; Se le resta uno al registro que controla el estado de esquive.
  jmp girar_izquierda ; Se salta a girar_izquierda.
esquivar_derecha:
  dec r7 ; Se le resta uno al registro que controla el estado de esquive.
  jmp girar_derecha ; Se salta girar_derecha.
esquivar_final:
  clr r7 ; Se pone en 0 porque termino esquive.
  jmp girar_izquierda ; Salta girar_izquierda.
fin_esquivar:
  RET

delay_500: ; Delay de 500ms
  rcall delay_250
  rcall delay_250
  RET

delay_1000: ; Delay de 1 seg.
  rcall delay_500
  rcall delay_500
  RET

delay_250: ; Delay de 250ms
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
