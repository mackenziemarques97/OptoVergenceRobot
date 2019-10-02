/*Serial.print()/Serial.println() prints/sends to serial port,
  which is then either read by MATLAB or printed in Serial Monitor
  depending on what serial port is connected to.
*/

/*Current notes/concerns:
   attempting to make speed constant throughout arc movement
   currently not smoother than using the same delay for all of the lines in the arc
   might need to change some of ints for speed and delay to longs, floats, etc. for preceision's sake
*/

/* Include the following libraries */
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
int stepsPerRev = 200; /*steps per revolution, for converting b/w cm input to steps*/
unsigned long microstepsPerStep = 16; /*divides each step into this many microsteps (us), determined by microstepping settings on stepper driver, (16 us/step)*(200 steps/rev)corresponds to 3200 pulse/rev*/
unsigned long dimensions[2] = {30000 * microstepsPerStep, 30000 * microstepsPerStep}; /*preallocating dimensions to previously measured values, arbitrary initialization value*/
unsigned long location[2] = {0, 0}; /*presetting location*/

int Delay = 30; /*default Delay for calibration and basic movement actions, in terms of square pulse width (microseconds)*/
float pi = 3.14159265359; /*numerical approximation used for pi*/
String val; /*String object to store inputs read from the Serial Connection*/
String coeffsString; /*String object to store speed model coefficients sent from MATLAB*/
float coeffsArray; /*for parsing speed model coefficients*/
double forward_coeffs[16]; /*used in delayToSpeed function*/
double reverse_coeffs[16]; /*used in speedToDelay function*/

/* Defines scaling factor for rotation
    radius of pulley
    will be multiplied by 2pi later in the code to get circumference
*/
float motor_radius = 0.65; //cm
float Circ = 2 * pi * motor_radius; /*circumference of pulley*/

/*TESTING
  arrays for storing movements and Delays from speedToDelay
  using 27 lines for small robot
  will likley increase to 55 to large robot
*/
double dx[38] = {0};
double dy[38] = {0};
double Delays[38] = {0};

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
  if (strcmp(fstr, "calibrate") == 0) { /*implement if first string is "calibrate"*/
    /* Calibrate
       No numerical inputs
    */
    static double inputs[1]; /*create inputs array with number of elements corresponding to number of inputs*/
    inputs[0] = 1; /*set first element in array to 1, switch case for calibrate*/
    return inputs;

  } else if (strcmp(fstr, "moveTo") == 0) { /*implement if first string is "move"*/
    /* Move to specific coordinate
       Numerical Inputs:
       (x0,y0) - destination coordinates in designated coordinate system
       hold - hold target at (x0,y0) for milliseconds
       move:x0:y0:hold duration
    */
    static double inputs[4];
    inputs[0] = 2; /*set first element in array to 2, switch case for move*/
    int i = 1;
    /*assign numerical inputs to spaces in array*/
    while (fstr != NULL) { /*implement while the first string is not empty*/
      fstr = strtok(NULL, delim); /*split entire string into tokens (individual strings), returns pointer to first token*/
      inputs[i++] = atof(fstr); /*converts string to a double and stores in the designated space in the array*/
    }
    return inputs;

  } else if (strcmp(fstr, "linearOscillate") == 0) { /*implement if first string is "oscillate"*/
    /* Oscillate between two specific coordinates
        Numerical Inputs:
       (x0,y0) and (x1,y1) - coordinates to move between in designated coordinate system
       Speed - delayMicroseconds between pulses
       Repetitions - Number of times to oscillate
       linearOscillate:x0:y0:x1:y1:speed:repetitions
    */
    static double inputs[7];
    inputs[0] = 3; /*set first element in array to 3, switch case for oscillate*/
    int i = 1;
    /*assign numerical inputs to spaces in array*/
    while (fstr != NULL) {
      fstr = strtok(NULL, delim);
      inputs[i++] = atof(fstr);
    }
    return inputs;

  } else if (strcmp(fstr, "arcMove") == 0) {
    /* Move in an arc
      Numerical inputs:
      diameter - in cm, converted to microsteps in switch case
      angInit - arc starts at this angle
      angFinal - arc ends at this angle
      Delay - delay in microseconds for each line movement
      arcRes - number of arc divisions
      arc:radius:angInit:angFinal:Delay:arcRes
    */
    static double inputs[6];
    inputs[0] = 4;
    int i = 1;
    while (fstr != NULL) {
      fstr = strtok(NULL, delim);
      inputs[i++] = atof(fstr);
    }
    return inputs;

  } else if (strcmp(fstr, "speedModelFit") == 0) {
    /*switch case
       speedModelFit:delayi:delayf:ddelay:angleTrials
    */
    static double inputs[5];
    inputs[0] = 5;
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

/*I do not need this function if I am calculating the Delays in MATLAB!
   Not sure if that is the method I will stick with, though.
*/
/*loadInfo function
   receive forward_ & reverse_coeffs strings sent from MATLAB
   parse coeffs into designated arrays
   first string defined as pointer variable
   once reverse_coeffs has been received, break from while loop
*/
void loadInfo() {
  Serial.println("ReadyToReceiveCoeffs"); /*signal MATLAB to begin send coeffs*/
  while (1) { /*loop through infinitely*/
    String coeffsString = Serial.readString();/*read characters from serial connection into String object*/
    /*this section of code is nearly identical to part of parseCommand function above*/
    if (coeffsString != NULL) {
      char inputArray[coeffsString.length() + 1];
      coeffsString.toCharArray(inputArray, coeffsString.length() + 1);
      float *coeffs = parseCoeffs(inputArray);
      if (*coeffs == 1) {
        Blink(BLUE);
        Serial.println("ForwardCoeffsReceived");
      }
      if (*coeffs == 2) {/*if the reverse_coeffs has been received from MATLAB*/
        Blink(GREEN);
        Serial.println("ReverseCoeffsReceived");
        break; /*break from the while loop*/
      }
    }
  }
}

/*parseCoeffs function
   parses coefficients sent through serial connection and returns coefficients array
   method nearly identical to that used in parseCommand function
*/
float* parseCoeffs(char strInput[]) {
  const char delim[2] = ":";
  char * strtokIn;
  strtokIn = strtok(strInput, delim);
  if (strcmp(strtokIn, "forward_coeffs") == 0) {
    static float coeffsArray[18]; /*preallocate space for designating forward or reverse coeffs and number of coefficients total*/
    coeffsArray[0] = 1; /*corresponds to forward_coeffs*/
    coeffsArray[1] = 16; /*16 coefficients in forward_coeffs*/
    int i = 2;
    while (strtokIn != NULL) {
      strtokIn = strtok(NULL, delim);
      coeffsArray[i++] = atof(strtokIn);
    }
    for (i = 0; i < 16; i++) {
      forward_coeffs[i] = coeffsArray[i + 2];
    }
    return coeffsArray;
  } else if (strcmp(strtokIn, "reverse_coeffs") == 0) {
    static float coeffsArray[18];
    coeffsArray[0] = 2; /*corresponds to reverse_coeffs*/
    coeffsArray[1] = 16; /*16 coefficients in reverse_coeffs*/
    int i = 2;
    while (strtokIn != NULL) {
      strtokIn = strtok(NULL, delim);
      coeffsArray[i++] = atof(strtokIn);
    }
    for (i = 0; i < 16; i++) {
      reverse_coeffs[i] = coeffsArray[i + 2];
    }
    return coeffsArray;
  }
}

void loadDelays() {
  Serial.println("ReadyToReceiveDelays"); /*signal MATLAB to begin send coeffs*/
  while (1) { /*loop through infinitely*/
    String coeffsString = Serial.readString();/*read characters from serial connection into String object*/
    /*this section of code is nearly identical to part of parseCommand function above*/
    if (coeffsString != NULL) {
      char inputArray[coeffsString.length() + 1];
      coeffsString.toCharArray(inputArray, coeffsString.length() + 1);
      float *coeffs = parseDelays(inputArray);
      if (*coeffs == 1) {
        Serial.println("DelaysReceived");
        Blink(GREEN);
      }
      else if (*coeffs == 2) {
        Serial.println("dxReceived");
      }
      else if (*coeffs == 3) {
        Serial.println("dyReceived");
        break;
      }
    }
  }
}

float* parseDelays(char strInput[]) {
  const char delim[2] = ":";
  char * strtokIn;
  strtokIn = strtok(strInput, delim);
  if (strcmp(strtokIn, "Delays") == 0) {
    static float coeffsArray[39]; /*preallocate space for designating forward or reverse coeffs and number of coefficients total*/
    coeffsArray[0] = 1; /*corresponds to Delays*/
    int i = 1;
    while (strtokIn != NULL) {
      strtokIn = strtok(NULL, delim);
      coeffsArray[i++] = atof(strtokIn);
    }
    for (i = 0; i < 38; i++) {
      Delays[i] = coeffsArray[i + 1];
    }
    return coeffsArray;
  }
  else if (strcmp(strtokIn, "dx") == 0) {
    static float coeffsArray[39]; /*preallocate space for designating forward or reverse coeffs and number of coefficients total*/
    coeffsArray[0] = 2; /*corresponds to dx*/
    int i = 1;
    while (strtokIn != NULL) {
      strtokIn = strtok(NULL, delim);
      coeffsArray[i++] = atof(strtokIn);
    }
    for (i = 0; i < 38; i++) {
      dx[i] = coeffsArray[i + 1];
    }
    return coeffsArray;
  }
  else if (strcmp(strtokIn, "dy") == 0) {
    static float coeffsArray[39]; /*preallocate space for designating forward or reverse coeffs and number of coefficients total*/
    coeffsArray[0] = 3; /*corresponds to dy*/
    int i = 1;
    while (strtokIn != NULL) {
      strtokIn = strtok(NULL, delim);
      coeffsArray[i++] = atof(strtokIn);
    }
    for (i = 0; i < 38; i++) {
      dy[i] = coeffsArray[i + 1];
    }
    return coeffsArray;
  }
}

/*Function to calculate delay from given speed
   likely the more useful than delayToSpeed
   inputs: reverse coefficients array, speed, angle
   calculate delay using 3rd degree polynomials nested in 2-term exponential
*/
double speedToDelay(double reverse_coeffs[], double Speed, double angle) {
  double complex_coeffs[4];
  for (int i = 0; i <= 3; i++) {
    double temp_coeff[4] = {reverse_coeffs[0 + i * 4], reverse_coeffs[1 + i * 4], reverse_coeffs[2 + i * 4], reverse_coeffs[3 + i * 4]};
    complex_coeffs[i] = poly3(temp_coeff, angle);
  }
  int Delay = exp2(complex_coeffs, Speed);
  return Delay;
}

/*Function to calculate speed from given delay
   inputs: forward coefficients array, delay, angle
   calculate speed using nested exp2 function
*/
double delayToSpeed(double forward_coeffs[], double Delay, double angle) {
  double complex_coeffs[4];
  for (int i = 0; i <= 3; i++) { /*loop through sets of 4 coefficients; correspond to a single function*/
    double temp_coeff[4] = {forward_coeffs[0 + i * 4], forward_coeffs[1 + i * 4], forward_coeffs[2 + i * 4], forward_coeffs[3 + i * 4]};
    complex_coeffs[i] = exp2(temp_coeff, Delay); /*get coefficients for nested exp2 equation*/
  }
  double Speed = exp2(complex_coeffs, angle); /*calculate speed, the output of the main exp2 equation*/
  return Speed;
}

/*3rd degree polynomial function
   inputs: 1x4 coefficients array, independent variable (x)
   calculates scalar output of function
*/
double poly3(double coeffs[], double x) {
  double output = coeffs[0] * pow(x, 3) + coeffs[1] * pow(x, 2) + coeffs[2] * x + coeffs[3];
  return output;
}

/*2 term exponential function
   inputs: 1x4 coefficients array, independent variable (x)
   calculates scalar output of function
*/
double exp2(double coeffs[], double x) {
  double output = coeffs[0] * exp(coeffs[1] * x) + coeffs[2] * exp(coeffs[3] * x);
  return output;
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
void line(int x1, int y1, int v) { /*inputs: x-component of vector, y-component of vector, speed/pulse width*/
  location[0] += x1; /*add x1 to current x-coordinate location*/
  location[1] += y1; /*add y1 to current y-coordinate location*/
  int x0 = 0, y0 = 0;
  int dx = abs(x1 - x0), signx = x0 < x1 ? 1 : -1; /*change in x is absolute value of difference between (x1,y1) location and origin*/
  /*if x0 is less than x1, set signx equal to 1; if x0 is not less than x1, set signx equal to -1*/
  /*if x-component of vector (desired x displacement) is positive, signx = 1 (clockwise rotation of motor)*/
  int dy = abs(y1 - y0), signy = y0 < y1 ? 1 : -1; /*same as above, except in terms of y*/
  int err = (dx > dy ? dx : -dy) / 2, e2; /*if dx is greater than dy, set error equal to dx/2; if dx is not greater than dy, set error equal to -dy/2*/
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

/* Main setup function
   Verifies serial connection and traces edges for dimensions
*/
void setup()
{ /*pulse and direction pins for x & y-dimension motors are outputting signal*/
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
  /*LED pins output*/
  pinMode(RED, OUTPUT);
  pinMode(GREEN, OUTPUT);
  pinMode(BLUE, OUTPUT);

  analogWrite(RED, ledOff); /*red off*/
  analogWrite(BLUE, ledOff); /*blue off*/
  analogWrite(GREEN, ledOff); /*green off*/

  digitalWrite(yDir, direction);
  digitalWrite(xDir, direction);
  /*set serial data transmission rate (baud rate)*/
  Serial.begin(9600);

  /* Communicates with Serial connection to verify */
  initialize();
  /* Sends coefficients for speed model */
  loadInfo();

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
  Blink(GREEN);
}

/* Main looping function
   Waits for commands from Serial Connection and executes actions
*/
void loop()
{
  Serial.flush();
  val = Serial.readString(); /*read characters from input into a String object*/

  /* Execute once there is incoming Serial information
     Parse incoming command from Serial connection
  */
  if (val != NULL) { /*if val is not empty*/
    char inputArray[val.length() + 1]; /*create an array the size of val string +1*/
    val.toCharArray(inputArray, val.length() + 1); /*convert val from String object to null terminated character array*/
    double *command = parseCommand(inputArray); /*create pointer variable to parsed commands*/
    /*put objects and variable initializations before start of switch case or block each case so variables remain within each scope*/
    long xDisp, yDisp;

    switch ((int) *command) { /*switch case based on first command*/
      case 1: // calibrate
        //GREEN
        {
          /* Calibrates to xMin and yMin and updates location to (0,0) */
          analogWrite(GREEN, ledOn); /*turn on green*/
          int xErr = recalibrate(xMin); /*xErr is number of steps from initial x-coordinate location to x=0*/
          int yErr = recalibrate(yMin); /*yErr is number of steps from initial y-coordinate location to y=0*/
          location[0] = 0;
          location[1] = 0;
          Serial.println("Done");
          delay(1000);
          analogWrite(GREEN, ledOff); /*turn off green*/
        }
        break;
      case 2: // moveTo:x0:y0:hold duration
        //BLUE
        {
          /* Simple move to designated location and holds for a certain time
          */
          long desiredXLoc = *(command + 1); //cm
          long desiredYLoc = *(command + 2); //cm
          int Delay = *(command + 3); //ms

          /*Converting inputs from cm to microsteps*/
          long xLocinuSteps = (long) ((desiredXLoc / Circ) * stepsPerRev * microstepsPerStep);
          long yLocinuSteps = (long) ((desiredYLoc / Circ) * stepsPerRev * microstepsPerStep);
          /*safety check, if the desired location is negative, move to (0,0)*/
          if (xLocinuSteps < 0) {
            xLocinuSteps = 0;
          }
          if (yLocinuSteps < 0) {
            yLocinuSteps = 0;
          }
          /*safety check, if the desired location is outside bounds of robot, constrain to boundaries*/
          if (xLocinuSteps > dimensions[0]) {
            xLocinuSteps = dimensions[0];
          };
          if (yLocinuSteps > dimensions[1]) {
            yLocinuSteps = dimensions[1];
          };
          /* displacement in scale of microsteps*/
          xDisp = xLocinuSteps - location[0];
          yDisp = yLocinuSteps - location[1];

          /*move by designated vector displacement*/
          analogWrite(BLUE, ledOn);/*turn on blue*/
          line(xDisp, yDisp, Delay);
          Serial.println("Done");
          analogWrite(BLUE, ledOff);/*turn off blue*/
        }
        break;
      case 3: // linearOscillate:x0:y0:x1:y1:speed:repetitions
        //RED
        {
          /* Linear Oscillate
             Moves to first coordinate and oscillates between that and second coordinate
          */
          long x0 = *(command + 1); //cm
          long y0 = *(command + 2); //cm
          long x1 = *(command + 3); //cm
          long y1 = *(command + 4); //cm
          int targetDelay = *(command + 5); //Units: us
          int numReps = *(command + 6); //number of repetitions/oscillations

          long xInit = (long) ((x0 / Circ) * stepsPerRev * microstepsPerStep); //x0 (cm) converted to steps
          long yInit = (long) ((y0 / Circ) * stepsPerRev * microstepsPerStep); //y0 (cm) converted to steps
          long xFinal = (long) ((x1 / Circ) * stepsPerRev * microstepsPerStep); //x1 (cm) converted to steps
          long yFinal = (long) ((y1 / Circ) * stepsPerRev * microstepsPerStep); //y1 (cm) converted to steps

          /*safety check: if the starting location is negative, set to (0,0)*/
          if (xInit < 0) { //if init loc in terms of steps is less than 0
            xInit = 0; //set init loc in terms of steps to 0
            x0 = 0; //set init loc in terms of cm to 0
          }
          if (yInit < 0) {
            yInit = 0;
            y0 = 0;
          }
          /*safety check: if starting location is outside bounds of bot, set to the boundary*/
          if (xInit > dimensions[0]) { //if init loc in terms of steps greater than max number of steps stored for x-dim
            xInit = dimensions[0]; //set init loc in terms of steps to dimension limit
            x0 = (dimensions[0] * Circ) / (stepsPerRev * microstepsPerStep); //set init loc in terms of cm to dimension limit converted to cm
          };
          if (yInit > dimensions[1]) {
            yInit = dimensions[1];
            y0 = (dimensions[1] * Circ) / (stepsPerRev * microstepsPerStep);
          };
          /*safety check, if the ending location is negative, set to (0,0)*/
          if (xFinal < 0) {
            xFinal = 0;
            x1 = 0;
          }
          if (yFinal < 0) {
            yFinal = 0;
            y1 = 0;
          }
          /*safety check, if ending location is outside bounds of bot, set to the boundary*/
          if (xFinal > dimensions[0]) {
            xFinal = dimensions[0];
            x1 = (dimensions[0] * Circ) / (stepsPerRev * microstepsPerStep);
          };
          if (yFinal > dimensions[1]) {
            yFinal = dimensions[1];
            y1 = (dimensions[1] * Circ) / (stepsPerRev * microstepsPerStep);
          };

          /*change in x/y, difference between initial x/y and final x/y adjusted for virtual dimension and size of system*/
          long dx = (long) (((x1 - x0) / Circ) * stepsPerRev * microstepsPerStep); /* Converting inputs from cm to microsteps*/
          long dy = (long) (((y1 - y0) / Circ) * stepsPerRev * microstepsPerStep);
          xDisp = (long) xInit - location[0];
          yDisp = (long) yInit - location[1];

          /*move along calculated displacement vector from current location to desired starting point*/
          analogWrite(RED, ledOn);/*turn on red*/
          line(xDisp, yDisp, Delay);
          delay(1000);
          long store_a = -dx / 2; /*ditto*/
          long store_b = -dy / 2; /*ditto*/
          int startDelay = 60; /*Minimum speed that target slows down to at edges of movement*/
          int dv = startDelay - targetDelay;
          /*vector from initial to final location scaled for...*/
          long dtx = (long) dx / (10 * dv / 2);
          long dty = (long) dy / (10 * dv / 2);

          for (int j = 1; j <= numReps; j++) { /*implemented number of times specified by repetitions input*/
            /* Speeds up in first 10% with intervals of 2 microseconds from min speed to max speed*/
            for (int i = 0; i < (int)dv / 2; i++) {
              int a = startDelay - i * 2;
              line(dtx, dty, a);
            }

            /* Moves middle 80% at max speed*/
            line((long) dx * 0.8, (long) dy * 0.8, targetDelay);

            /* Slows down end 10% */
            for (int i = 0; i < (int)dv / 2; i++) {
              int a = targetDelay + i * 2;
              line(dtx, dty, a);
            }

            /* Speeds up end 10% back */
            for (int i = 0; i < (int)dv / 2; i++) {
              int a = startDelay - i * 2;
              line(-dtx, -dty, a);
            }

            /* Moves middle 80% back at max speed*/
            line((long) - dx * 0.8, (long) - dy * 0.8, targetDelay);

            /* Slows down end 10% back*/
            for (int i = 0; i < (int) dv / 2; i++) {
              int a = targetDelay + i * 2;
              line(-dtx, -dty, a);
            }
          }
          analogWrite(RED, ledOff);/*turn off red*/
          Serial.println("Done");
          delay(1000);
        }
        break;
      case 4: // arcMove:diameter:angInit:angFinal:delayArc/speed:numLines
        // 1:1 ratio between arcRes and number of lines used to draw the arc
        // TESTING - conversion from speed to delay
        // model only incorporates angles between 0 and 45 degrees using origin of (xMin, yMin)
        //RED & BLUE
        {
          int dcm = *(command + 1); //diameter in cm
          //safety check: diameter of arc
          if ( dcm > 35  ) { //diameter is greater than max limit of x-dim
            Serial.println("EntryError");
            break;
          }
          float dsteps = (dcm / Circ) * stepsPerRev * microstepsPerStep; //diameter in microsteps
          float Rcm = dcm / 2; //radius in cm
          float Rsteps = (Rcm / Circ) * stepsPerRev * microstepsPerStep; //radius is calculated from diameter (R = d/2) and converted from cm to microsteps
          int angInit = *(command + 2); //starting angle in degrees
          int angFinal = *(command + 3); //final angle in degrees
          double Speed = *(command + 4); //this input not currently used, will be used when speed model is integrated
          int numLines = *(command + 5); //number of lines used to form the arc movement for version movement
          float arcRes = (numLines - 1) / 3; //adjustment of numLines for calculation
          
          float angInit_rad = (pi / 180) * (-angInit + 90); /*convert initial angle from degrees to radians*/
          float angFinal_rad = (pi / 180) * (-angFinal + 90); /*convert final angle from degrees to radians then adjust by input resolution*/
          float angInit_res = angInit_rad * arcRes;
          float angFinal_res = angFinal_rad * arcRes;
          
          long dispInitx = dimensions[0] * 0.5 + ((float) Rsteps) * cos(angInit_rad) - location[0];
          long dispInity = ((float) Rsteps) * sin(angInit_rad) - location[1];

          analogWrite(RED, ledOn);
          analogWrite(BLUE, ledOn);

          //TESTING

          //int count = 0;
          //for (int i = angInit_res; i <= angFinal_res; i++) {
          //Serial.println(count);
          //double dx = {round(-Rsteps / arcRes * sin((float)i / arcRes))}; /*change in x-direction, derivative of rcos(theta) adjusted for resolution*/
          //Serial.println(dx);
          //double dy = {Rsteps / arcRes * cos((float)i / arcRes)}; /*change in y-direction, derivative of rsin(theta) adjusted for resolution*/
          //Serial.println(dy);
          //double angle = abs(atan2(dy, dx) * (180 / pi));
          //Serial.println(angle);
          //if (angle >= 90 && angle <= 135) {
          //  angle = angle - 90;
          //}
          //else if (angle > 135 && angle <= 180) {
          //  angle = angle - 135;
          //}
          //double Delays[count] = {speedToDelay(reverse_coeffs, Speed, angle)};
          //count++;
          //}

          //count = 0;
          //for (int i = angInit_res; i <= angFinal_res; i++) { /*move from initial to final angle*/
          //line(dx[count], dy[count], Delay); /*draw small line, which represents part of circle/arc*/
          //count++;
          //}

          //TEST

          //The following code accomplishes arc movement, but at inconsistent speeds.
          line(dispInitx, dispInity, Delay); /*move to initial position, x-direction: center + rcos(angInit), y-direction: 0 + rsin(angInit)*/
          if ( angInit_rad < angFinal_rad ) {
            for (int i = angInit_res; i <= angFinal_res; i++) {
              int dx = round(-Rsteps / arcRes * sin((float)i / arcRes));
              int dy = round(Rsteps / arcRes * cos((float)i / arcRes));
              line(dx, dy, Delay);
            }
          }
          else if ( angInit_res > angFinal_rad ) {
            for (int i = angInit_res; i >= angFinal_res; i--) {
              int dx = round(Rsteps / arcRes * sin((float)i / arcRes));
              int dy = round(-Rsteps / arcRes * cos((float)i / arcRes));
              line(dx, dy, Delay);
            }
          }

          analogWrite(RED, ledOff);
          analogWrite(BLUE, ledOff);
          Serial.println("Done");
        }
        break;
      case 5: //speedModelFit:delayi:delayf:ddelay:angleTrials
        {
          /* Speed Trials
             Still needs testing
          */
          int delayi, delayf, ddelay, angleTrials;
          /*assign commands to variables*/
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
          Serial.println("Beginning");
          Serial.println(ddistance);
          /* Number of loops for speed and angles*/
          int delaytrials = (int) ((delayf - delayi) / ddelay + 1); /*currently does nothing*/
          /* Intialize loop arrays that will be sent over*/
          unsigned long speedRuns[angleTrials];
          int xDistance[angleTrials];
          int yDistance[angleTrials];
          int trialNum;

          /* Delay Loop */
          for (int j = delayi; j <= delayf; j += ddelay) {
            int targetDelay = j;
            Serial.println("Delay");
            /* Angle Loop */
            /*origin of xMin,yMin ; 0 to 45 degrees*/
            for (int i = 0; i <= maxDistance; i += ddistance) {
              recalibrate(yMin);
              recalibrate(xMin);
              delay(300);
              int x = maxDistance; // Steps
              int y = i;
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
            for (int i = 0; i < angleTrials; i++) {
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
