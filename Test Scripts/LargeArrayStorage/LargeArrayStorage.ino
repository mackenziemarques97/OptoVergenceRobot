#include <avr/pgmspace.h>

const PROGMEM double delayArc[1000] = {};

/*confirm serial connection function
 * initialize serialInit as X
 * send A to MATLAB
 * expecting to receive A
 * if doeS not receive A, then continue reading COM port and blinking red LED
 */
void initialize() {
  char serialInit = 'X';
  Serial.println("A");
  while (serialInit != 'A') 
  {
    serialInit = Serial.read();
    //Blink(RED);
  }
}

void setup() {
 Serial.begin(9600);
 initialize();
}

void loop() {
  Serial.println("Beginning"); 


  //Serial.println(delayArc[999]);
  
}
