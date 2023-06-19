#include "codigo.h"
#include <AFMotor.h>
#include <Servo.h>

//Definición de registros
volatile uint8_t *R07=(volatile uint8_t*)0x0007;
volatile uint8_t *R09=(volatile uint8_t*)0x0009;
volatile uint8_t *R10=(volatile uint8_t*)0x000A;
volatile uint8_t *R11=(volatile uint8_t*)0x000B;
volatile uint8_t *R14=(volatile uint8_t*)0x000E;
volatile uint8_t *R15=(volatile uint8_t*)0x000F;
volatile uint8_t *R16=(volatile uint8_t*)0x0010;
volatile uint8_t *R17=(volatile uint8_t*)0x0011;
volatile uint8_t *R19=(volatile uint8_t*)0x0013;
volatile uint8_t *R20=(volatile uint8_t*)0x0014;
volatile uint8_t *R21=(volatile uint8_t*)0x0015;
volatile uint8_t *R22=(volatile uint8_t*)0x0016;

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
  cabezal.attach(10);         //Asigno el pin 10 al servo (corresponde a la salida SERVO_1 del shield)
  cabezal.write(*R17);        //Función que escribe un ángulo al servomotor. 90 es mirando al frente
  // FOWARD = 1, BACKWARD = 2, BRAKE = 3
  // Ver https://github.com/adafruit/Adafruit-Motor-Shield-library/blob/d81504057474e940de7f0a0934f19c626846a154/AFMotor.h#L108-L109
  M1.run(FORWARD);           //Asigno direccion al motor1
  M2.run(FORWARD);           //Asigno direccion al motor2
}

void loop() {
  servo_centro();           // Se pone el servo en el centro en el 90° (R17).
  cabezal.write(*R17);
  avanzar();                // Se setea los registros R19 y R20 para que los motores avanzan.
  M1.setSpeed(*R19);        
  M2.setSpeed(*R20);

  *R21=medirdistancia();    // Uso de la funcion medir distancia y guardado en R21
  check_distancia();        // Checkea que si la distancia es mayor a 30, se coloca un 0 en R16, de lo contrario se pone un 1.

  if (*R16 == 1 || (*R07 < 4 && *R07 > 0)) {
    frenar();               // Se setea la velocidad de los motores en 0 para que no se desplace el auto.
    M1.setSpeed(*R19);
    M2.setSpeed(*R20);
    delay_250();

    mirar_dos_lados(cabezal);  // Se llama a mirar lados y se pasa como argumento cabezal que controla servo. 
    esquivar();                // Se llama a la función esquivar.
    M1.setSpeed(*R19);         // Esquivar termina seteando valores para los motores.
    M2.setSpeed(*R20);         // Dependiendo de la logica se setean determinado valores.
    delay_250();
  }
}

/*
Función que controla gira el servo a la derecha y escribe en el R10 la distancia.
Luego gira el servo a la izquierda y guarda en R09 la distancia izquierda.
*/
void mirar_dos_lados(Servo cabezal) {
  servo_derecha();
  cabezal.write(*R17);
  delay_250();
  *R10 = medirdistancia();
  delay_500();

  servo_izquierda();
  cabezal.write(*R17);
  delay_250();
  *R09 = medirdistancia();
  delay_500();
}
