/*This sketch is intended to integrate the LED board (controlled by an Arduino Mega 2560)
   with the spMaster-LED MATLAB GUI.
*/

/*Include the following libraries*/
#include <stdio.h>
#include <math.h>
#include <EEPROMex.h>
#include <FastLED.h> //contains specific commands used to interact with LED pixels

/*Define pins for the x-axis stepper motor*/
#define xPulse 8 /*50% duty cycle pulse width modulation*/
#define xDir 9 /*rotation direction*/
/*Define pins for the z-axis stepper motor*/
#define zPulse 10
#define zDir 11
/*Define pins for the 4 microswitches*/
#define xMin 2
#define xMax 3
#define zMin 4
#define zMax 5
/*Define pins for RGB LED*/
#define RED 22
#define GREEN 23
#define BLUE 24
/*Define pins for interacting with photodiode*/
#define cReset 50 //resets the photodiode
#define dLatchOut 51 //contains state of the latch, currently unused
/*Define LED pins on Arduino for each direction strip*/
#define N_Strip 30 //bluewhite
#define NW_Strip 31 //yellowblack
#define NE_Strip 32 //black
#define S_Strip 33 //purple
#define SW_Strip 34 //greenwhite
#define SE_Strip 35 //brown
#define W_Strip 36 //white
#define E_Strip 37 //blue
/*Define LED pin on Arduino for center LED*/
#define Center 38 //brownblack

#define BRIGHTNESS  100 /* valid values between 0 and 255 */
#define LED_TYPE    WS2812B
#define COLOR_ORDER GRB

/*Define number of direction strips*/
#define NUM_STRIPS 8
/*Define number of LEDs in each direction strip*/
#define NUM_LEDS_PER_STRIP 23
/*Define one LED in the center*/
#define NUM_Center 1

/*Create an array of LED arrays to represent the direction strips*/
/*CRGB is an object representing a color in RGB color space*/
CRGB leds_Strips[NUM_STRIPS][NUM_LEDS_PER_STRIP];
/*Create an array for center LED*/
CRGB leds_Center[NUM_Center];

/*Define global variables*/
unsigned long previousMillis;
unsigned long currentMillis;
int addressLongX, addressLongZ; //address/bytes to write dimensions to
int dirIndex, colIndex;
bool robotLEDTracker = false;
String val;
const int ledOff = 255;
const int ledOn = 127;
int direction = 1; /*viewing from behind motor, with shaft facing away, 1 = clockwise, 0 = counterclockwise*/
const int stepsPerRev = 200; /*steps per revolution, for converting b/w cm input to steps*/
unsigned long microstepsPerStep = 16; /*divides each step into this many microsteps (us), determined by microstepping settings on stepper driver, (16 us/step)*(200 steps/rev)corresponds to 3200 pulse/rev*/
unsigned long dimensions[2]; /*preallocating dimensions to previously measured values, arbitrary initialization value*/
unsigned long location[2] = {0, 0}; /*presetting location*/
int Delay = 30; /*default Delay for calibration and basic movement actions, in terms of square pulse width (microseconds)*/
float pi = 3.14159265359; /*numerical approximation used for pi*/
/* Defines scaling factor for rotation
    radius of pulley
    will be multiplied by 2pi later in the code to get circumference
*/
float motor_radius = 0.65; //cm
float Circ = 2 * pi * motor_radius; /*circumference of pulley*/

/*This function assigns an integer to each direction strip. User enters direction
   as a string and that is stored as an index.
*/
int setDirIndex(const char* token) {
  /* case/capitalization of strings matters */
  if (strcmp(token, "N") == 0) { /* if 2nd command entry is N */
    dirIndex = 0; /* put 0 in position 1 of command[] */
  }
  else if (strcmp(token, "NW") == 0) { /* if 2nd command entry is NW */
    dirIndex = 1; /* put 1 in command[1] */
  }
  else if (strcmp(token, "NE") == 0) { /* if 2nd command entry is NE */
    dirIndex = 2; /* put 2 in command[1] */
  }
  else if (strcmp(token, "S") == 0) { /* if 2nd command entry is S */
    dirIndex = 3; /* put 3 in command[1] */
  }
  else if (strcmp(token, "SW") == 0) { /* if 2nd command entry is SW */
    dirIndex = 4; /* put 4 in command[1] */
  }
  else if (strcmp(token, "SE") == 0) { /* if 2nd command entry is SE */
    dirIndex = 5; /* put 5 in command[1] */
  }
  else if (strcmp(token, "W") == 0) { /* if 2nd command entry is W */
    dirIndex = 6; /* put 6 in command[1] */
  }
  else if (strcmp(token, "E") == 0) { /* if 2nd command entry is E */
    dirIndex = 7; /* put 7 in command[1] */
  }
  else if (strcmp(token, "center") == 0) { /* if 2nd command entry is center */
    dirIndex = 8; /* put 8 in command[1] */
  }
  return dirIndex;
}

/*This function assigns an integer to each color. User enters color
   as a string and that is stored as an index.
*/
int setColorIndex(const char* token) {
  /*case/capitalization of strings matters*/
  if (strcmp(token, "red") == 0) { /*if entry is "red"*/
    colIndex = 1; /*save index as 1*/
  }
  else if (strcmp(token, "green") == 0) { /*if entry is "green"*/
    colIndex = 2; /*save index as 2*/
  }
  else if (strcmp(token, "blue") == 0) { /*if entry is "blue"*/
    colIndex = 3; /*save index as 3*/
  }
  else if (strcmp(token, "yellow") == 0) { /*if entry is "blue"*/
    colIndex = 4; /*save index as 4*/
  }
  else if (strcmp(token, "magenta") == 0) { /*if entry is "blue"*/
    colIndex = 5; /*save index as 5*/
  }
  else if (strcmp(token, "black") == 0) { /*if entry is "blue"*/
    colIndex = 6; /*save index as 6*/
  }
  else { /* otherwise */
    colIndex = -1; /*save index as arbitrary placeholder -1 ~ nothing execute in this case*/
  }
  return colIndex;
}

/*This function parses inputs for controlling LED board into pointer variable*/
/*command numbering - 0:1:2:3:4:5...*/
double* parseCommand(char strCommand[]) {
  const char delim[2] = ":"; /*delimiter between inputs declared as :*/
  char *token;
  token = strtok(strCommand, delim); /*start to split string into tokens (tokens separated by delimiter :)*/

  if (strcmp(token, "sendLEDPhaseParams") == 0) { /*switch case 1 - sendPhaseParams*/
    static double command[5]; /*5 numerical double command entries are required - sendPhaseParams:direction:color:degree offset:time on*/
    command[0] = 1; /*first number in command array indicates switch case ( 1 = "sendPhaseParams" )*/
    int i = 1;
    while (token != NULL) {
      token = strtok(NULL, delim);
      /*the following if statement assigns numbers to string command entries*/
      if (i == 1) { /*i = 1 indicates 2nd command entry - if looping through and parsing 2nd command entry*/
        command[i] = setDirIndex(token); /*store index that corresponds to the direction entered*/
        i++;
      }
      else if (i == 2) { /*i = 2 indicates 3rd command entry - if looping through and parsing 3rd command entry*/
        command[i] = setColorIndex(token); /*store index that corresponds to the color entered*/
        i++;
      }
      else { /*for rest of command entries (which should be integers)*/
        command[i++] = atof(token); /*save them in command array*/
      }
    }
    return command;
  }

  if (strcmp(token, "turnOnLED") == 0) { /*switch case 2 - showLEDs*/
    static double command[1]; /*1 numerical double command entry is required - showLEDs:*/
    command[0] = 2; /*first number in command array indicates switch case ( 2 = "showLEDs" )*/
    return command;
  }
  if (strcmp(token, "turnOffLED") == 0) { /*switch case 2 - showLEDs*/
    static double command[1]; /*1 numerical double command entry is required - showLEDs:*/
    command[0] = 3; /*first number in command array indicates switch case ( 2 = "showLEDs" )*/
    return command;
  }
  if (strcmp(token, "clearLEDs") == 0) { /*switch case 2 - showLEDs*/
    static double command[1]; /*1 numerical double command entry is required - showLEDs:*/
    command[0] = 4; /*first number in command array indicates switch case ( 2 = "showLEDs" )*/
    return command;
  }
  if (strcmp(token, "sendRobotPhaseParams") == 0) { /*switch case 2 - showLEDs*/
    static double command[1]; /*1 numerical double command entry is required - showLEDs:*/
    command[0] = 5; /*first number in command array indicates switch case ( 2 = "showLEDs" )*/
    int i = 1;
    while (token != NULL) {
      token = strtok(NULL, delim);
      /*the following if statement assigns numbers to string command entries*/
      if (i == 1) { /*i = 1 indicates 2nd command entry - if looping through and parsing 2nd command entry*/
        command[i] = setColorIndex(token); /*store index that corresponds to the color entered*/
        i++;
      }
      else { /*for rest of command entries (which should be integers)*/
        command[i++] = atof(token); /*save them in command array*/
      }
    }
    return command;
  }
  if (strcmp(token, "returnRobot") == 0) { /*switch case 2 - showLEDs*/
    static double command[1]; /*1 numerical double command entry is required - showLEDs:*/
    command[0] = 6; /*first number in command array indicates switch case ( 2 = "showLEDs" )*/
    return command;
  }
  if (strcmp(token, "findDimensions") == 0) { /*switch case 2 - showLEDs*/
    static double command[1]; /*1 numerical double command entry is required - showLEDs:*/
    command[0] = 7; /*first number in command array indicates switch case ( 2 = "showLEDs" )*/
    return command;
  }

}

/*This function accepts degree entries and saves the equivalent position in the strip.*/
int checkDegree(int dir, int deg) {
  int ledNum;
  if (dir == 8) {
    ledNum = 0;
  }
  else {
    if (deg == 25) { /*if degree offset from center LED is 25*/
      ledNum = 20; /*save ledNum as 20 - that is the position in the strip assigned to LED with 25 degree offset*/
    }
    else if (deg == 30) { /*if degree offset is 30*/
      ledNum = 21; /*save ledNum as 21*/
    }
    else if (deg == 35) { /*if degree offset is 35*/
      ledNum = 22; /*save ledNum as 22*/
    }
    else if (deg > 35) { /*no LEDs beyond a 35 degree offset*/
      ledNum = -1; /*assign arbitrary placeholder ledNum of -1*/
    }
    else if ((deg > 20 && deg < 25) || (deg > 25 && deg < 30) || (deg > 30 && deg < 35)) { /*no LEDs between 20 and 25 or 25 and 30 or 30 and 35 degrees*/
      ledNum = -1; /*assign arbitrary placeholder deg of -1 so they won't light up*/
    }
    else { /*in any other case*/
      ledNum = deg - 1; /*subtract 1 to convert degree offset entry to position in strip*/
    }
  }
  return ledNum;
}

/*This function sets the color of the specified LED based on index saved in command[]*/
void setLEDColor(int dir, int col, int ledNum) { /*dir, col, ledNum are all integers stored in command []; re-stored in named variables at start of each switch case*/
  /*if turning on center LED*/
  if (dir == 8) {
    if (col == 1) {
      leds_Center[0] = CRGB::Red; /*only one LED in leds_Center, index 0*/
    }
    else if (col == 2) {
      leds_Center[0] = CRGB::Green; /*first and only LED accessed as leds_Center[0]*/
    }
    else if (col == 3) {
      leds_Center[0] = CRGB::Blue;
    }
    else if (col == 4) {
      leds_Center[0] = CRGB::Yellow;
    }
    else if (col == 5) {
      leds_Center[0] = CRGB::Magenta;
    }
    else if (col == 6) {
      leds_Center[0] = CRGB::Black;
    }
  }
  /*if turning on LEDs in any of the strips*/
  else {
    if (col == 1) {
      leds_Strips[dir][ledNum] = CRGB::Red; /*leds_Strips is an array of arrays*/
    }
    else if (col == 2) {
      leds_Strips[dir][ledNum] = CRGB::Green; /*outer array (dir) refers to each direction strip*/
    }
    else if (col == 3) {
      leds_Strips[dir][ledNum] = CRGB::Blue; /*inner array (ledNum) refers to one of the 23 LEDs in each direction strip*/
    }
    else if (col == 4) {
      leds_Strips[dir][ledNum] = CRGB::Yellow; /*inner array (ledNum) refers to one of the 23 LEDs in each direction strip*/
    }
    else if (col == 5) {
      leds_Strips[dir][ledNum] = CRGB::Magenta; /*inner array (ledNum) refers to one of the 23 LEDs in each direction strip*/
    }
    else if (col == 6) {
      leds_Strips[dir][ledNum] = CRGB::Black; /*inner array (ledNum) refers to one of the 23 LEDs in each direction strip*/
    }
  }
}

/* This function turns off LED
  regardless of whether in leds_Center or leds_Strips
*/
void turnOffLED(int dir, int ledNum) {
  if (dir == 8) {
    leds_Center[0] = CRGB::Black; FastLED.show(); /* set LED to black, then display */
  }
  else {
    leds_Strips[dir][ledNum] = CRGB::Black; FastLED.show();
  }
}

/* recalibrate function:
   Moves LED to specified edge (xMax, xMin, zMax, zMin)
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
    } else if (pin == zMin) { /*if pin is zMin*/
      line(0, -microstepsPerStep * 10, Delay); /*move in negative z-direction toward zMin*/
    } else if (pin == zMax) { /*if pin is zMax*/
      line(0, microstepsPerStep * 10, Delay); /*move in positive z-direction toward zMax*/
    }
    steps += 10; /*add 10 to steps counter*/

    if (steps > (long) dimensions[1] * 1.2) { /*if the number of steps is greater than 120% of the number of steps of the z-dimension*/
      Serial.end(); /*end the serial connection*/
      break; /*break out of the loop*/
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
        } else if (pin == zMin) {
          line(0, microstepsPerStep, Delay); /*if zMin microswitch is pressed, move forward in z-direction*/
          location[1] = 0; /*update z-coordinate location to 0*/
          delay(200);
        } else if (pin == zMax) {
          line(0, -microstepsPerStep, Delay); /*if zMax microswitch is pressed, move back in negative z-direction*/
          location[1] = dimensions[1]; /*update z-coordinate location to max z-dimension*/
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
void line(long x1, long z1, int v) { /*inputs: x-component of vector, z-component of vector, speed/pulse width*/
  location[0] += x1; /*add x1 to current x-coordinate location*/
  location[1] += z1; /*add z1 to current z-coordinate location*/
  long x0 = 0, z0 = 0;
  long dx = abs(x1 - x0), signx = x0 < x1 ? 1 : -1; /*change in x is absolute value of difference between (x1,z1) location and origin*/
  /*if x0 is less than x1, set signx equal to 1; if x0 is not less than x1, set signx equal to -1*/
  /*if x-component of vector (desired x displacement) is positive, signx = 1 (clockwise rotation of motor)*/
  long dz = abs(z1 - z0), signy = z0 < z1 ? 1 : -1; /*same as above, except in terms of y*/
  long err = (dx > dz ? dx : -dz) / 2, e2; /*if dx is greater than dz, set error equal to dx/2; if dx is not greater than dz, set error equal to -dz/2*/
  digitalWrite(xDir, (signx + 1) / 2); /*setup x motor rotation direction, if signx = 1, rotate counterclockwise; if signx = -1, don't move*/
  digitalWrite(zDir, (signy + 1) / 2); /*setup y motor rotation direction*/
  for (;;) { /*infinite loop (;;)*/
    if (x0 == x1 && z0 == z1) break; /*once the desired location is reached, break out of the infinite loop and halt movement*/
    e2 = err; /*to maiantain error at start of loop, since error changes in some cases*/
    if (e2 > -dx) { /*if error is greater than negative dx*/
      err -= dz; /*subtract dz from the error*/
      x0 += signx; /*add signx (1 or -1) to the x-coordinate location*/
      /*HIGH to LOW represents one cycle of square wave, which corresponds to motor rotation*/
      digitalWrite(xPulse, HIGH);
      if (e2 < dz) { /*if error is less than dz*/
        err += dx; /*add dx to error*/
        z0 += signy; /*add signy (1 or -1) to the z-coordinate location*/
        /*motors of both dimensions moving*/
        digitalWrite(zPulse, HIGH);
        delayMicroseconds(v);
        digitalWrite(xPulse, LOW);
        digitalWrite(zPulse, LOW);
        delayMicroseconds(v);
      } else {
        delayMicroseconds(v);
        digitalWrite(xPulse, LOW);
        delayMicroseconds(v);
      }
    } else if (e2 < dz) {
      err += dx;
      z0 += signy;
      /*z-dimension motor movement*/
      digitalWrite(zPulse, HIGH);
      delayMicroseconds(v);
      digitalWrite(zPulse, LOW);
      delayMicroseconds(v);
    }
  }
}

/* findDimensions function:
   Moves to xMax from current location then to xMin and counts the number of steps it took
   Does the same in the z-direction
   Returns the number of steps in a 2-element array, x & z dimension
   Ends at (xMin, zMin)
*/
int* findDimensions() {
  recalibrate(xMax); /*move to xMax*/
  int a = recalibrate(xMin); /*a = number of steps necessary to move from xMax to xMin*/
  recalibrate(zMax); /*move to zMax*/
  int b = recalibrate(zMin); /*b = number of steps necessary to move from zMax to zMin*/
  static int i[2] = {a, b}; /*store x & z dimensions in an array in terms of number of steps*/
  return i;
}

void writeDimensions(unsigned long dimensions[]) {
  long xDim = dimensions[0];
  EEPROM.updateLong(addressLongX, xDim);
  Serial.print("xDim: "); Serial.println(xDim);
  long zDim = dimensions[1];
  EEPROM.updateLong(addressLongZ, zDim);
  Serial.print("zDim: "); Serial.println(zDim);
}

int setRobotColor(int colIndex) {
  int ledPin;
  if (colIndex == 1) {
    ledPin = RED;
  }
  else if (colIndex == 2) {
    ledPin = GREEN;
  }
  else if (colIndex == 3) {
    ledPin = BLUE;
  }
  else {
    ledPin = -1;
  }
  return ledPin;
}


void setup() {
  /*initialize pins and settings*/
  FastLED.addLeds<LED_TYPE, N_Strip, COLOR_ORDER>(leds_Strips[0], NUM_LEDS_PER_STRIP).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, NW_Strip, COLOR_ORDER>(leds_Strips[1], NUM_LEDS_PER_STRIP).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, NE_Strip, COLOR_ORDER>(leds_Strips[2], NUM_LEDS_PER_STRIP).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, S_Strip, COLOR_ORDER>(leds_Strips[3], NUM_LEDS_PER_STRIP).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, SW_Strip, COLOR_ORDER>(leds_Strips[4], NUM_LEDS_PER_STRIP).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, SE_Strip, COLOR_ORDER>(leds_Strips[5], NUM_LEDS_PER_STRIP).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, W_Strip, COLOR_ORDER>(leds_Strips[6], NUM_LEDS_PER_STRIP).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, E_Strip, COLOR_ORDER>(leds_Strips[7], NUM_LEDS_PER_STRIP).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, Center, COLOR_ORDER>(leds_Center, NUM_Center).setCorrection( TypicalLEDStrip );

  FastLED.setBrightness( BRIGHTNESS );

  /*pulse and direction pins for x & z-dimension motors are outputting signal*/
  pinMode(xPulse, OUTPUT);
  pinMode(xDir, OUTPUT);
  pinMode(zPulse, OUTPUT);
  pinMode(zDir, OUTPUT);
  /*microswitch pins are awaiting input signal (pressed or unpressed)*/
  pinMode(xMin, INPUT);
  pinMode(xMax, INPUT);
  pinMode(zMin, INPUT);
  pinMode(zMax, INPUT);
  /*LED pins output*/
  pinMode(RED, OUTPUT);
  pinMode(GREEN, OUTPUT);
  pinMode(BLUE, OUTPUT);
  /*photodiode pins*/
  pinMode(cReset, OUTPUT);
  pinMode(dLatchOut, INPUT);
  /*preset RGB LED to off*/
  analogWrite(RED, ledOff);
  analogWrite(BLUE, ledOff);
  analogWrite(GREEN, ledOff);
  /*preset stepper motor direction pins to 1*/
  digitalWrite(zDir, direction);
  digitalWrite(xDir, direction);
  /*preset microswitch pins to HIGH (1), indicating unpressed*/
  digitalWrite(xMin, HIGH);
  digitalWrite(xMax, HIGH);
  digitalWrite(zMin, HIGH);
  digitalWrite(zMax, HIGH);

  /*set serial data transmission rate (baud rate)*/
  Serial.begin(115200);
  Serial.setTimeout(35);

  digitalWrite(cReset, HIGH);
  delay(100);

  /* get addresses/bytes to write to in EEPROM */
  addressLongX = EEPROM.getAddress(sizeof(long));
  addressLongZ = EEPROM.getAddress(sizeof(long));
  /* read from EEPROM */
  long EEPROMoutput = EEPROM.readLong(addressLongX);
  /* store in first position of dimensions array */
  dimensions[0] = EEPROMoutput;
  /* read from EEPROM */
  EEPROMoutput = EEPROM.readLong(addressLongZ);
  /* store in second position of dimensions array */
  dimensions[1] = EEPROMoutput;

  char serialInit = 'X';
  Serial.println("A");
  while (serialInit != 'A')
  {
    serialInit = Serial.read();
  }
}

void loop() {
  int dir, ledNum;
  Serial.flush();
  val = Serial.readString(); /*read characters from serial connection into a String object*/
  /* Executes once there is incoming Serial information
     Parse incoming command from Serial connection
  */
  if (val != NULL) { /*if val is not empty*/
    char inputArray[val.length() + 1]; /*create an array the size of val string +1*/
    val.toCharArray(inputArray, val.length() + 1); /*convert val from String object to null terminated character array*/
    double *command = parseCommand(inputArray); /*create pointer variable to parsed commands*/
    switch ((int) *command) { /*switch case based on first command entry*/
      /*saves parameters for controlling single LED*/
      case 1://sendLEDPhaseParams:dir:color:degree
        {
          dir = * (command + 1); /*direction strip*/
          int color = * (command + 2); /*color*/
          int deg = * (command + 3); /*degree offset from center of LED*/
          ledNum = checkDegree(dir, deg); /*converts degree entry to LED position in strip*/
          setLEDColor(dir, color, ledNum); /*sets and saves color of specified LED*/
          if (color != -1) { /*color will be -1 if something other than red,green,blue,yellow,magenta,black is received from MATLAB*/
            leds_Strips[6][22] = CRGB::Red; /*photodiode LED ~ set 35 degree LED in W strip to turn on anytime any other LED turns on*/
          }
          Serial.println(leds_Center[0]);
        }
        break;
      /*displays any changes made to LEDs*/
      case 2: //turnOnLED:
        {
          digitalWrite(cReset, LOW); /*reset photodiode before turning on LED*/
          digitalWrite(cReset, HIGH);
          FastLED.show(); /*turn on LEDs*/
          Serial.println("LEDon");
        }
        break;
      /*turns off specified LED*/
      case 3: //turnOffLED:
        {
          turnOffLED(dir, ledNum); /*turn off LED*/
          Serial.println("LEDoff");
        }
        break;
      /* turns off all LEDs*/
      case 4: //clearLEDs:
        {
          FastLED.clear();
          FastLED.show();
          Serial.println("LEDsCleared");
        }
        break;
      /*saves parameters for controlling robot*/
      case 5://sendRobotPhaseParams:color:x1:y1:moveDur:LEDdur:currentPhase:startRobotPhase:lastRobotPhase:currentTrial:startTrial:lastTrial
        {   long interval = *(command + 5) * 1000;
            long xDisp = *(command + 2) - location[0];
            long zDisp = *(command + 3) - location[1];
            double dur = *(command + 4);

            //double v = sqrt(pow(xDisp,2)+pow(zDisp,2))/dur;
            int ledPin = setRobotColor(*(command + 1));
          
          while (1) {
            if (ledPin != -1 && !robotLEDTracker) {
              if (interval != 0) {
               previousMillis = millis();
              }
              analogWrite(ledPin, ledOn);
              robotLEDTracker = true;
//              Serial.println("ON");
            }

            if (interval == 0) {
              int baseDelay = 70;
              int dv = baseDelay - Delay;
              long dtx = (long) xDisp / (10 * dv / 2);
              long dtz = (long) zDisp / (10 * dv / 2);

              Serial.println("MovementStarted");


              for (int i = 0; i < (int)dv / 2; i++) {
                int a = baseDelay - i * 2;
                line(dtx, dtz, a);
              }

              line((long) xDisp * 0.8, (long) zDisp * 0.8, Delay);

              for (int i = 0; i < (int)dv / 2; i++) {
                int a = Delay + i * 2;
                line(dtx, dtz, a);
              }
              break;
            }

            currentMillis = millis();
//            Serial.print("Interval: "); Serial.println(interval);
//            Serial.print("millisDifference: "); Serial.println(currentMillis - previousMillis);

            if (interval != 0 && currentMillis - previousMillis >= interval) {
              previousMillis = currentMillis;
              analogWrite(ledPin, ledOff);
              robotLEDTracker = false;
              Serial.println("OFF");
              break;
            }
            if (interval == 0 && ledPin != -1 && robotLEDTracker && (*(command + 6) == *(command + 8)) && (*(command + 9) == *(command + 11))) {
              analogWrite(ledPin, ledOff);
              robotLEDTracker = false;
//              Serial.println("OFF2");
              break;
            }
          }
        }
        break;
      case 6: //returnRobot:
        {
          /* Calibrates to xMin and zMin and updates location to (0,0) */
          recalibrate(xMin); /*xErr is number of steps from initial x-coordinate location to x=0*/
          recalibrate(zMin); /*zErr is number of steps from initial z-coordinate location to z=0*/
          location[0] = 0;
          location[1] = 0;
          Serial.println("robotReturned");
          delay(300);
        }
        break;
      case 7: //findDimensions:
        {
          /* Determines dimensions by moving from xMax to xMin, then zMax to zMin*/
          int *i = findDimensions();
          dimensions[0] = *i * microstepsPerStep;
          dimensions[1] = *(i + 1) * microstepsPerStep;
          /* writes dimensions to EEPROM */
          writeDimensions(dimensions);
          Serial.println("dimensionsFound");
          delay(300);
        }
        break;
    }
  }
}
