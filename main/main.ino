#include "codigo.h"
#include <AFMotor.h>
#include <Servo.h>

//Definición de registros
volatile uint8_t *R10=(volatile uint8_t*)0x000A;
volatile uint8_t *R11=(volatile uint8_t*)0x000B;
volatile uint8_t *R14=(volatile uint8_t*)0x000E;
volatile uint8_t *R15=(volatile uint8_t*)0x000F;
volatile uint8_t *R16=(volatile uint8_t*)0x0010;
volatile uint8_t *R17=(volatile uint8_t*)0x0011;
volatile uint8_t *R18=(volatile uint8_t*)0x0012;
volatile uint8_t *R19=(volatile uint8_t*)0x0013;
volatile uint8_t *R20=(volatile uint8_t*)0x0014;
volatile uint8_t *R21=(volatile uint8_t*)0x0015;

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
  cabezal.write(*R17);
  avanzar();
  M1.setSpeed(*R19);
  M2.setSpeed(*R20);

  *R21=medirdistancia();  //Uso de la funcion medir distancia y guardado en R21
  check_distancia();
  if (*R16 == 1) {
    frenar();
    M1.setSpeed(*R19);
    M2.setSpeed(*R20);
    delay(250);
    mirar_dos_lados(cabezal);
    M1.setSpeed(*R19);
    M2.setSpeed(*R20);
    //delay_250();
    delay(250);
  }
  delay(1000);
}

void mirar_dos_lados(Servo cabezal) {
  servo_derecha();
  cabezal.write(*R17);
  delay(250);
  *R10 = medirdistancia();
  delay(500);
  

  servo_izquierda();
  cabezal.write(*R17);
  delay(250);
  *R11 = medirdistancia();
  delay(500);

  elegir_lado();
}