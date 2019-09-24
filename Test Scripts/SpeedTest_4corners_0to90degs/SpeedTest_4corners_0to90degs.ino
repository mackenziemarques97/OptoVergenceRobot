/*In speedModelFit, create a loop that goes through
   origin of (xMin, yMin) at 0-45 degrees [(maxDist, 0)-(maxDist,maxDist)] and 45-90 degrees [(maxDist,maxDist)-(0,maxDist)]
   (xMin, yMax) at 0-45 degrees [(maxDist, 0)-(maxDist,-maxDist)] and 45-90 degrees [(maxDist,-maxDist)-(0,-maxDist)]
   (xMax, yMin) at 0-45 degrees [(-maxDist, 0)-(-maxDist,maxDist)] and 45-90 degrees [(-maxDist,maxDist)-(0,maxDist)]
   (xMax, yMax) at 0-45 degrees [(-maxDist, 0)-(-maxDist,-maxDist)] and 45-90 degrees [(-maxDist,-maxDist)-(0,-maxDist)]
*/

#include <stdio.h>
#include <math.h>

/* Defining pins */
/*pins for the x-axis stepper motor*/
#define xPulse 8 /*50% duty cycle pulse width modulation*/
#define xDir 9 /*rotation direction*/
/*pins for the y-axis stepper motor*/
#define yPulse 10
#define yDir 11
/*pins for the 4 microswitchces*/
#define xMin 2
#define xMax 3
#define yMin 4
#define yMax 5
/*pins for RGB LED*/
#define RED 48
#define GREEN 49
#define BLUE 50

/* Define initial variables and arrays */
int ledOff = 255;
int ledOn = 127;
int direction = 1; /*viewing from behind motor, with shaft facing away, 1 = clockwise, 0 = counterclockwise*/
unsigned long stepsPerRev = 200; /*steps per revolution, for converting b/w cm input to steps*/
unsigned long microstepsPerStep = 16; /*divides each step into this many microsteps (us), determined by microstepping settings on stepper driver, (16 us/step)*(200 steps/rev)corresponds to 3200 pulse/rev*/
unsigned long dimensions[2] = {30000 * microstepsPerStep, 30000 * microstepsPerStep}; /*preallocating dimensions to previously measured values, arbitrary initialization value*/
unsigned long location[2] = {0, 0}; /*presetting location*/

int Delay = 30; /*default Delay for calibration and basic movement actions, in terms of square pulse width (microseconds)*/
float pi = 3.14159265359; /*numerical approximation used for pi*/
String infoFromSerialConnection; /*String object to store inputs read from the Serial Connection*/

/*Blink an LED twice
   input: specific LED pin
   that pin must be set to HIGH first
*/
void Blink(int LED) {
  analogWrite(LED, ledOn);
  delay(300);
  analogWrite(LED, ledOff);
  delay(300);
  analogWrite(LED, ledOn);
  delay(300);
  analogWrite(LED, ledOff);
  delay(300);
}

/*Confirm serial connection function
   initialize serialInit as X
   send A to MATLAB
   expecting to receive A
   if does not receive A, then continue reading COM port and blinking red LED
*/
void initialize() {
  char serialInit = 'X';
  Serial.println("A");
  while (serialInit != 'A')
  {
    serialInit = Serial.read();
    Blink(RED);
  }
}

/*Parse commands received from Serial Connection and return designated inputs to MATLAB*/
double* parseCommand(char strCommand[]) { /*inputs are null terminated character arrays*/
  const char delim[2] = ":"; /*unchangeable character, 2 element array designating the delimiter as :*/
  char *fstr; /*first string defined as a pointer variable*/
  fstr = strtok(strCommand, delim); /*first call: determines first input of the string*/
  if (strcmp(fstr, "speedModelFit") == 0) {
    /*switch case
       speedModelFit:delayi:delayf:ddelay:angleTrials
    */
    static double inputs[5];
    inputs[0] = 1;
    int i = 1;
    while (fstr != NULL) {
      fstr = strtok(NULL, delim);
      inputs[i++] = atof(fstr);
    }
    return inputs;

  } else { /*implement in any other case*/
    static double j[1];
    j[0] = 10000;
    return j;
  }
}

/* findDimensions function:
   Moves to xMax from current location then to xMin and counts the number of steps it took
   Does the same in the y-direction
   Returns the number of steps in a 2-element array, x & y dimension
   Ends at (xMin, yMin)
*/
int* findDimensions() {
  recalibrate(xMax); /*move to xMax*/
  int a = recalibrate(xMin); /*a = number of steps necessary to move from xMax to xMin*/
  recalibrate(yMax); /*move to yMax*/
  int b = recalibrate(yMin); /*b = number of steps necessary to move from yMax to yMin*/
  static int i[2] = {a, b}; /*store x & y dimensions in an array in terms of number of steps*/
  return i;
}

/* recalibrate function:
   Moves target to specified edge (xMax, xMin, yMax, yMin)
   Standardizes edge as the point when the microswitch is just released.
   Returns number of steps it took to get there
   0 = pressed, 1 = unpressed for pin reads
*/
unsigned long recalibrate(int pin) { /*input is microswitch pin*/
  delay(1000);
  unsigned long steps = 0;
  /*Specific pin recalibration/movement toward that pin*/
  int val = digitalRead(pin); /*read the pin, 0 = pressed, 1 = unpressed*/
  while (val) {
    if (pin == xMin) { /*if pin is xMin*/
      line(-microstepsPerStep * 10, 0, Delay); /*move in negative x-direction toward xMin*/
    } else if (pin == xMax) { /*if pin is xMax*/
      line(microstepsPerStep * 10, 0, Delay); /*move in positive x-direction toward xMax*/
    } else if (pin == yMin) { /*if pin is yMin*/
      line(0, -microstepsPerStep * 10, Delay); /*move in negative y-direction toward yMin*/
    } else if (pin == yMax) { /*if pin is yMax*/
      line(0, microstepsPerStep * 10, Delay); /*move in positive y-direction toward yMax*/
    }
    steps += 10; /*add 10 to steps counter*/


    if (steps > (long) dimensions[1] * 1.2) { /*if the number of steps is greater than 120% of the number of steps of the y-dimension*/
      Serial.end(); /*end the serial connection*/
      break; /*break put of the loop*/
    }

    /*Overshoot adjustment: moves back until pin is just released*/
    val = digitalRead(pin);
    if (val == 0) { /*if switch is pressed*/
      while (val == 0) { /*while switch is pressed*/
        if (pin == xMin) {
          line(microstepsPerStep, 0, Delay); /*if xMin microswitch is pressed (if value read from pin is 0), move forward in x-direction*/
          location[0] = 0; /*update x-coordinate location to 0*/
          delay(200);
        } else if (pin == xMax) {
          line(-microstepsPerStep, 0, Delay); /*if xMax microswitch is pressed, move back in negative x-direction*/
          location[0] = dimensions[0]; /*update x-coordinate location to max x-dimension*/
          delay(200);
        } else if (pin == yMin) {
          line(0, microstepsPerStep, Delay); /*if yMin microswitch is pressed, move forward in y-direction*/
          location[1] = 0; /*update y-coordinate location to 0*/
          delay(200);
        } else if (pin == yMax) {
          line(0, -microstepsPerStep, Delay); /*if yMax microswitch is pressed, move back in negative y-direction*/
          location[1] = dimensions[1]; /*update y-coordinate location to max y-dimension*/
          delay(200);
        }
        val = digitalRead(pin); /*continue reading the state of the pin*/
        steps -= 1; /*remove one step from total step count, correcting for the overshoot*/
      }
      break; /*when val no longer is 0, switch has just been released, break from the loop*/
    }
  }
  return steps; /*returns the number of steps*/
}


/* Implementation of Bresenham's Algorithm for a line
   Input vector (in number of steps) along with pulse width (delay, which determines speed)
   Proprioceptive location
*/
void line(long x1, long y1, int v) { /*inputs: x-component of vector, y-component of vector, speed/pulse width*/
  location[0] += x1; /*add x1 to current x-coordinate location*/
  location[1] += y1; /*add y1 to current y-coordinate location*/
  long x0 = 0, y0 = 0;
  long dx = abs(x1 - x0), signx = x0 < x1 ? 1 : -1; /*change in x is absolute value of difference between (x1,y1) location and origin*/
  /*if x0 is less than x1, set signx equal to 1; if x0 is not less than x1, set signx equal to -1*/
  /*if x-component of vector (desired x displacement) is positive, signx = 1 (clockwise rotation of motor)*/
  long dy = abs(y1 - y0), signy = y0 < y1 ? 1 : -1; /*same as above, except in terms of y*/
  long err = (dx > dy ? dx : -dy) / 2, e2; /*if dx is greater than dy, set error equal to dx/2; if dx is not greater than dy, set error equal to -dy/2*/
  digitalWrite(xDir, (signx + 1) / 2); /*setup x motor rotation direction, if signx = 1, rotate counterclockwise; if signx = -1, don't move*/
  digitalWrite(yDir, (signy + 1) / 2); /*setup y motor rotation direction*/
  for (;;) { /*infinite loop (;;)*/
    if (x0 == x1 && y0 == y1) break; /*once the desired location is reached, break out of the infinite loop and halt movement*/
    e2 = err; /*to maiantain error at start of loop, since error changes in some cases*/
    if (e2 > -dx) { /*if error is greater than negative dx*/
      err -= dy; /*subtract dy from the error*/
      x0 += signx; /*add signx (1 or -1) to the x-coordinate location*/
      /*HIGH to LOW represents one cycle of square wave, which corresponds to motor rotation*/
      digitalWrite(xPulse, HIGH);
      if (e2 < dy) { /*if error is less than dy*/
        err += dx; /*add dx to error*/
        y0 += signy; /*add signy (1 or -1) to the y-coordinate location*/
        /*motors of both dimensions moving*/
        digitalWrite(yPulse, HIGH);
        delayMicroseconds(v);
        digitalWrite(xPulse, LOW);
        digitalWrite(yPulse, LOW);
        delayMicroseconds(v);
      } else {
        delayMicroseconds(v);
        digitalWrite(xPulse, LOW);
        delayMicroseconds(v);
      }
    } else if (e2 < dy) {
      err += dx;
      y0 += signy;
      /*y-dimension motor movement*/
      digitalWrite(yPulse, HIGH);
      delayMicroseconds(v);
      digitalWrite(yPulse, LOW);
      delayMicroseconds(v);
    } else {
    }
  }
}

void setup() {
  /*pulse and direction pins for x & y-dimension motors are outputting signal*/
  pinMode(xPulse, OUTPUT);
  pinMode(xDir, OUTPUT);
  pinMode(yPulse, OUTPUT);
  pinMode(yDir, OUTPUT);
  /*microswitch pins are awaiting input signal (pressed or unpressed)*/
  pinMode(xMin, INPUT);
  pinMode(xMax, INPUT);
  pinMode(yMin, INPUT);
  pinMode(yMax, INPUT);
  /*initially set microswitch pins to HIGH (1), indicating unpressed*/
  digitalWrite(xMin, HIGH);
  digitalWrite(xMax, HIGH);
  digitalWrite(yMin, HIGH);
  digitalWrite(yMax, HIGH);

  digitalWrite(yDir, direction);
  digitalWrite(xDir, direction);
  /*set serial data transmission rate (baud rate)*/
  Serial.begin(9600);

  /* Communicates with Serial connection to verify */
  initialize();


  /* Determines dimensions by moving from xmax to xmin, then ymax to ymin*/
  int *i = findDimensions(); /*pointer of the array that contains the x & y-dimensions in terms of steps*/
  /* Scales dimensions to be in terms of microsteps (from steps)
      The following dimensions are to use when findDimensions() is commented out.
      big bot dimensions: x = 106528, y = 54624
      small bot dimensions: x = 28640, y = 31984
  */
  dimensions[0] = *i * microstepsPerStep; /*x-dimension*/
  dimensions[1] = *(i + 1) * microstepsPerStep; /*y-dimension*/

  Serial.println("Ready");
}

void loop() {
  Serial.flush();
  infoFromSerialConnection = Serial.readString(); /*read characters from input into a String object*/

  if (infoFromSerialConnection != NULL) {
    char inputArray[infoFromSerialConnection.length() + 1]; /*create an array the size of val string +1*/
    infoFromSerialConnection.toCharArray(inputArray, infoFromSerialConnection.length() + 1); /*convert val from String object to null terminated character array*/
    double *command = parseCommand(inputArray); /*create pointer variable to parsed commands*/
    switch ((int) *command) {
      case 1: //modified speed data collection
        {
          int delayi, delayf, ddelay, angleTrials;
          delayi = (int) * (command + 1);
          delayf = (int) * (command + 2);
          ddelay = (int) * (command + 3);
          angleTrials = (int) * (command + 4);

          /*determine smallest dimension between x and y*/
          long minDim = min((long)(dimensions[0] / microstepsPerStep), (long)(dimensions[1] / microstepsPerStep));
          /*determine divisions of 90% of min dimension, based on the number of angle trials*/
          int ddistance = (int) (0.9 * minDim / (angleTrials - 1));
          /*maxDistance = 0.9*minDim, or 90% of the length of the smallest dimension*/
          int maxDistance = ddistance * (angleTrials - 1);
          Serial.println(ddistance);
          int totalAngles = (angleTrials * 2) - 1;

          /* Intialize loop arrays that will be sent over*/
          unsigned long speedRuns[totalAngles];
          int xDistance[totalAngles];
          int yDistance[totalAngles];
          /* Delay Loop */
          int trialNum;

          /* Delay Loop */
          for (int del = delayi; del <= delayf; del += ddelay) {
            int targetDelay = del;
            Serial.println("Delay");
            /* Angle Loop */
            /*origin of xMin,yMin ; 0 to 45 degrees; change in y */
            for (int dy = 0; dy <= maxDistance; dy += ddistance) {
              recalibrate(xMin);
              recalibrate(yMin);
              delay(300);
              int x = maxDistance; // Steps
              int y = dy;
              /* Calculate how long it takes to move to specified position at specified delayMicroseconds */
              long startTime = millis();
              line((long) x * microstepsPerStep, (long) y * microstepsPerStep, targetDelay);
              long endTime = millis();
              long timed = endTime - startTime;
              /* Saving information in appropriate arrays*/
              speedRuns[trialNum] = timed;
              xDistance[trialNum] = x;
              yDistance[trialNum] = y;
              trialNum++;
              delay(300);
            }
            /*origin of xMin,yMin ; 45 to 90 degrees, excluding 45 since collected in last loop; change in x*/
            for (int dx = maxDistance - ddistance; dx <= 0; dx -= ddistance) {
              recalibrate(xMin);
              recalibrate(yMin);
              delay(300);
              int x = dx; // Steps
              int y = maxDistance;
              /* Calculate how long it takes to move to specified position at specified delayMicroseconds */
              long startTime = millis();
              line((long) x * microstepsPerStep, (long) y * microstepsPerStep, targetDelay);
              long endTime = millis();
              long timed = endTime - startTime;
              /* Saving information in appropriate arrays*/
              speedRuns[trialNum] = timed;
              xDistance[trialNum] = x;
              yDistance[trialNum] = y;
              trialNum++;
              delay(300);
            }

            /*Send x and y distances and time after each delay trial
              used to calculate Euclidean speed in MATLAB*/
            Serial.println("Sending");
            for (int i = 0; i < totalAngles; i++) {
              Serial.println(speedRuns[i]);
              Serial.println(xDistance[i]);
              Serial.println(yDistance[i]);
            }
            trialNum = 0;
          }
          Serial.println("Done");
        }
        break;
    }
  }
}
