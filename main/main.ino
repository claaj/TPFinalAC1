//#include <Arduino.h>
#include "codigo.h"
#include <AFMotor.h>
#include <Servo.h>


//Definición de registros
uint8_t *R10=(uint8_t*)0X0A;
int8_t *R11=(uint8_t*)0X0B;
uint8_t *R12=(uint8_t*)0X0C;
//.....
uint8_t *R16=(uint8_t*)0X10;
uint8_t *R17=(uint8_t*)0X11;
uint8_t *R18=(uint8_t*)0X12;
uint8_t *R19=(uint8_t*)0X13;

//Definición de objetos de bibliotecas
Servo cabezal;        //Servomotor
AF_DCMotor M1(1);     //Motor 1
AF_DCMotor M2(2);     //Motor 2

uint_8 checkear_adelante();

void checkear_distancias() {
  if (checkear_adelante() < 30) {
    if (checkear_derecha() < 30) {
      doblar_derecha();
    }
    else if (checkear_izquierda() < 30) {
      doblar_izquierda();
    }
    else {
      giro_180();
    }
  }
}

void checkear_laterales(){
      if (checkear_derecha() < 30) {
      doblar_derecha();
    }
    else if (checkear_izquierda() < 30) {
      doblar_izquierda();
    }
    else {
      reversa_poquito()
    }
}

void checkear_laterales2(){
      if (checkear_izquierda() < 30) {
      doblar_derecha();
    }
    else if (checkear_derecha() < 30) {
      doblar_izquierda();
    }
    else {
      reversa_poquito()
    }
}


uint8_t medirdistancia(){
  float tiempo_de_espera;
  float resultado; //Declaramos variables de tipo flotante
  //long tiempo_de_espera;
  digitalWrite (A1,LOW);      //ponemos en bajo el pin A1 durante 5 microsegundos
  delayMicroseconds(5);
  digitalWrite (A1,HIGH);     //ahora ponemos en alto pin A1 durante 10 microsegundos
  delayMicroseconds(10);    
  digitalWrite (A1,LOW);     //y lo volvemos a bajar
  tiempo_de_espera = pulseIn(A0,HIGH); //Medimos el tiempo que A0 se mantiene encendido
  resultado=(tiempo_de_espera/2)/29.15;   //Convertimos a CM

  if (resultado>255){resultado=255;}  //Limitamos a 255 (8 bits)
  int res_int=(int)resultado; //Convertimos a entero
  Serial.println(resultado);
  uint8_t res_byte=(uint8_t)res_int;  //y a uint8_t
  return res_byte;
}


void setup() {
  pinMode(A0, INPUT);
  pinMode(A1, OUTPUT);
  cabezal.attach(10);         //Asigno el pin 10 al servo (corresponde a la salida SERVO_1 del shield)
  cabezal.write(90); //Función que escribe un ángulo al servomotor.
                     // 90 es mirando al frente
  //M1.run(FORWARD);            //Asigno direccion a los motores
  //M2.run(FORWARD);
  /*...
  Aquí iría la funcion de
  configuración de
  entradas y salidas
  ... */
  Serial.begin(9600);
}

void loop() {

  *R19=medirdistancia();  //Uso de la funcion medir distancia y guardado en R16

  /*...
  Aquí irian las llamadas a las funciones en assembler
  ...*/

  //girar_derecha();
  //M1.setSpeed(*R10); //   -> EJEMPLO
  //M2.setSpeed(*R11); //   -> EJEMPLO
  //cabezal.write(0);
  delay(500);
  //servo();
  //cabezal.write(*R16);
  //delay(1000);
}
