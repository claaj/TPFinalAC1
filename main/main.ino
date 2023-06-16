#include "codigo.h"
#include <AFMotor.h>
#include <Servo.h>

//Definición de registros
uint8_t *R10=(uint8_t*)0X0A;
uint8_t *R11=(uint8_t*)0X0B;
uint8_t *R12=(uint8_t*)0X0C;
//.....
uint8_t *R15=(uint8_t*)0X0F;
uint8_t *R16=(uint8_t*)0X10;
uint8_t *R17=(uint8_t*)0X11;
uint8_t *R18=(uint8_t*)0X12;
uint8_t *R19=(uint8_t*)0X13;
uint8_t *R20=(uint8_t*)0X14;
uint8_t *R21=(uint8_t*)0X15;
uint8_t *R22=(uint8_t*)0X16;

//Definición de objetos de bibliotecas
Servo cabezal;        //Servomotor
AF_DCMotor M1(1);     //Motor 1
AF_DCMotor M2(2);     //Motor 2

uint8_t medirdistancia(){
  float tiempo_de_espera,resultado; //Declaramos variables de tipo flotante
  digitalWrite (A1,LOW);      //ponemos en bajo el pin A1 durante 5 microsegundos
  delayMicroseconds(5);
  digitalWrite (A1,HIGH);     //ahora ponemos en alto pin A1 durante 10 microsegundos
  delayMicroseconds(10);    
  digitalWrite (A1,LOW);     //y lo volvemos a bajar
  tiempo_de_espera = pulseIn(A0,HIGH,1000000); //Medimos el tiempo que A0 se mantiene encendido
  resultado=(tiempo_de_espera/2)/29.15;   //Convertimos a CM

  if (resultado>255){resultado=255;}  //Limitamos a 255 (8 bits)
  int res_int=(int)resultado;         //Convertimos a entero
  uint8_t res_byte=(uint8_t)res_int;  //y a uint8_t
  return res_byte;
}

void setup() {
  setup_asm();
  cabezal.attach(10);   //Asigno el pin 10 al servo (corresponde a la salida SERVO_1 del shield)
  cabezal.write(*R17);  //Función que escribe un ángulo al servomotor. 90 es mirando al frente
  // FOWARD = 1, BACKWARD = 2, BRAKE = 3
  // Ver https://github.com/adafruit/Adafruit-Motor-Shield-library/blob/d81504057474e940de7f0a0934f19c626846a154/AFMotor.h#L108-L109
  M1.run(FORWARD);      //Asigno direccion al motor1
  M2.run(FORWARD);      //Asigno direccion al motor2
  Serial.begin(9600);   //Inicar Serial para poder imprimir.
}

void loop() {
  servo_centro();
  avanzar();
  M1.setSpeed(*R19);
  M2.setSpeed(*R20);
  cabezal.write(*R17);

  *R21=medirdistancia();  //Uso de la funcion medir distancia y guardado en R21
  Serial.println(*R21);
  check_distancia();
  Serial.println(*R15);
  if (*R15 == 1) {
    mirar_dos_lados(cabezal);
    M1.setSpeed(*R19);
    M2.setSpeed(*R20);
    delay_250();
  }
  delay_1000();
}

void mirar_dos_lados(Servo cabezal) {
  servo_derecha();
  cabezal.write(*R17);
  //Serial.println(*R17);
  delay_500();
  *R10 = medirdistancia();
  
  servo_izquierda();
  cabezal.write(*R16);
  //Serial.println(*R17);
  delay_500();
  *R11 = medirdistancia();

  elegir_lado();
}