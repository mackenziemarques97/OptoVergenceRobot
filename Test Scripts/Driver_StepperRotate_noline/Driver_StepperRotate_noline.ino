/*TEST CODE: Rotate shaft of a single stepper motor back and forth.
   For testing effect of stepper motor + driver + Arduino on monkey neural recordings.
*/

#include <stdio.h>
#include <math.h>

#define xPulse 10 /*50% duty cycle pulse width modulation*/
#define xDir 11 /*rotation direction*/

int Delay = 60; /*delay/pulse width in microseconds*/
int rot_time = 500; /*rotation time*/
unsigned long time_stamp; /*time stamp using millis()*/
int Direction;

void setup() {
  pinMode(xPulse, OUTPUT);
  pinMode(xDir, OUTPUT);
}

void loop() {
  time_stamp = millis();
  for (;;) {
    Direction = 1; /*staring directly at the shaft, 1 is counterclockwise, 0 is clockwise*/
    digitalWrite(xDir, Direction);
    digitalWrite(xPulse, HIGH);
    delayMicroseconds(Delay);
    digitalWrite(xPulse, LOW);
    delayMicroseconds(Delay);
    if (millis() == time_stamp + rot_time){
      break;
    }
  }
  delay(1000); /*pause time between direction switch*/
  time_stamp = millis();
  for(;;) {
    Direction = 0;
    digitalWrite(xDir, Direction);
    digitalWrite(xPulse, HIGH);
    delayMicroseconds(Delay);
    digitalWrite(xPulse, LOW);
    delayMicroseconds(Delay);
    if (millis() == time_stamp + rot_time){
      break;
    }
  }
  delay(1000); /*pause time between direction switch*/
}
