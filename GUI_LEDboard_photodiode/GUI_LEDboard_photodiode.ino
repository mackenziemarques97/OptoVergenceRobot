/*This sketch is intended to integrate the LED board (controlled by an Arduino Mega 2560)
   with the spMaster-LED MATLAB GUI.
*/

/*Include the following libraries*/
#include <stdio.h>
#include <math.h>
#include <FastLED.h> //contains specific commands used to interact with LED pixels

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
int dir, color, ledNum;
double timeOn;
int dirIndex, colIndex;
String val;

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

  if (strcmp(token, "sendPhaseParams") == 0) { /*switch case 1 - sendPhaseParams*/
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

}

/*This function accepts degree entries and saves the equivalent position in the strip.*/
int checkDegree(int dir, int deg) {
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
void setColor(int dir, int col, int ledNum) { /*dir, col, ledNum are all integers stored in command []; re-stored in named variables at start of each switch case*/
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

  pinMode(cReset, OUTPUT);
  pinMode(dLatchOut, INPUT);

  /*set serial data transmission rate (baud rate)*/
  Serial.begin(9600);
  Serial.setTimeout(20);

  digitalWrite(cReset, HIGH);
  delay(100);

  char serialInit = 'X';
  Serial.println("A");
  while (serialInit != 'A')
  {
    serialInit = Serial.read();
  }

  Serial.println("startSignalReceived");
}

void loop() {
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
      case 1://sendPhaseParams:dir:color:degree:timeon
        {
          dir = * (command + 1); /*direction strip*/
          color = * (command + 2); /*color*/
          int deg = * (command + 3); /*degree offset from center of LED*/
          timeOn = * (command + 4) * 1000; /*time LED is on, in seconds*/
          ledNum = checkDegree(dir, deg); /*converts degree entry to LED position in strip*/
          setColor(dir, color, ledNum); /*sets and saves color of specified LED*/
          if (color != -1){ /*color will be -1 if something other than red,green,blue,yellow,magenta,black is received from MATLAB*/
            leds_Strips[6][22] = CRGB::Red; /*photodiode LED ~ set 35 degree LED in W strip to turn on anytime any other LED turns on*/
          }
          Serial.println("phaseParamsSent");
        }
        break;
      /*displays any changes made to LEDs*/
      case 2: //turnOnLED
        {
          digitalWrite(cReset, LOW); /*reset photodiode before turning on LED*/
          digitalWrite(cReset, HIGH);
          FastLED.show(); /*turn on LEDs*/
          Serial.println("LEDon");
        }
        break;
      /*turns off specified LED*/
      case 3: //turnOffLED
        {
          turnOffLED(dir, ledNum); /*turn off LED*/
          Serial.println("LEDoff");
        }
        break;
      /* turns off all LEDs*/
      case 4: //clearLEDs
        {
          FastLED.clear();
          FastLED.show();
          Serial.println("LEDsCleared");
        }
        break;
    }
  }
}
