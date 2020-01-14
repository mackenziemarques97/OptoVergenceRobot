/* Include the following libraries */
#include <stdio.h>
#include <math.h>
#include <FastLED.h>

/*LED pins on Arduino for each direction strip*/
#define N_Strip 30 //bluewhite
#define NW_Strip 31 //yellowblack
#define NE_Strip 32 //black
#define S_Strip 33 //purple
#define SW_Strip 34 //greenwhite
#define SE_Strip 35 //brown
#define W_Strip 36 //white
#define E_Strip 37 //blue
/*LED pin on Arduino for center LED*/
#define Center 38 //brownblack

#define BRIGHTNESS  100 /* valid values between 0 and 255 */
#define LED_TYPE    WS2812B
#define COLOR_ORDER GRB

/*define number of direction strips*/
#define NUM_STRIPS 8
/*define number of LEDs in each direction strip*/
#define NUM_LEDS_PER_STRIP 23
/*define one LED in the center*/
#define NUM_Center 1

/*create an array of LED arrays to represent the direction strips*/
CRGB leds_Strips[NUM_STRIPS][NUM_LEDS_PER_STRIP]; /* CRGB is an object representing a color in RGB color space */
/*create an array for center LED*/
CRGB leds_Center[NUM_Center];

/* Define initial variables and arrays */
int dir, color, ledNum;
double timeOn;
int dirIndex, colIndex;
String val;

int setDirIndex(const char* token) {
  /* integers in command[1] indicate directions */
  /* case/capitalization matters */
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

int setColorIndex(const char* token) {
  /* integers in command[2] indicate LED colors */
  /* case/capitalization matters */
  if (strcmp(token, "red") == 0) { /* if 3rd command entry is red */
    colIndex = 1; /* put 1 in command[2] */
  }
  else if (strcmp(token, "green") == 0) { /* if 3rd command entry is green */
    colIndex = 2; /* put 2 in command[2] */
  }
  else if (strcmp(token, "blue") == 0) { /* if 3rd command entry is blue */
    colIndex = 3; /* put 3 in command[2] */
  }
  else { /* otherwise */
    colIndex = -1; /* put arbitrary,placeholder -1 in command[2] */
  }
  return colIndex;
}

/* function to parse inputs for controlling LED into pointer variable */
/* command numbering - 0:1:2:3:4:5... */
double* parseCommand(char strCommand[]) {
  const char delim[2] = ":"; /*delimiter between inputs declared as :*/
  char *token;
  token = strtok(strCommand, delim);
  if (strcmp(token, "sendPhaseParams") == 0) { /*switch case 1 - oneLED*/
    static double command[5]; /*5 numerical double command entries are required - oneLED:direction:color:degree offset:time on*/
    command[0] = 1; /*first number in command array indicates switch case ( 1 = oneLED )*/
    int i = 1;
    while (token != NULL) {
      token = strtok(NULL, delim);
      /*the following if statement assigns numbers to string command entries*/
      if (i == 1) { /* i = 1 indicates 2nd command entry - if looping through and parsing 2nd command entry */
        command[i] = setDirIndex(token);
        i++;
      }
      else if (i == 2) { /* i = 2 indicates 3rd command entry - if looping through and parsing 3nd command entry */
        command[i] = setColorIndex(token);
        i++;
      }
      else { /* for rest of command entries (which should be integers) */
        command[i++] = atof(token); /* put them in command array */
      }
    }

    return command;
  }
    if (strcmp(token, "showLEDs") == 0) { /*switch case 1 - oneLED*/
    static double command[1]; /*5 numerical double command entries are required - oneLED:direction:color:degree offset:time on*/
    command[0] = 2; /*first number in command array indicates switch case ( 1 = oneLED )*/
    return command;
  }
}

/* function to set the color of the specified LED based on number in command[] */
void setColor(int dir, int col, int deg) { /* dir, col, deg are all integers stored in command []; re-stored in named variables at start of each switch case */
  /* if turning on center LED */

  if (dir == 8) {
    if (col == 1) {
      leds_Center[0] = CRGB::Red; /* only one LED in leds_Center */
    }
    else if (col == 2) {
      leds_Center[0] = CRGB::Green; /* first and only LED accessed as leds_Center[0] */
    }
    else if (col == 3) {
      leds_Center[0] = CRGB::Blue;
    }
  }
  /* if turning on LEDs in any of the strips */
  else {
    if (col == 1) {
      leds_Strips[dir][deg] = CRGB::Red; /* leds_Strips is an array of arrays */
    }
    else if (col == 2) {
      leds_Strips[dir][deg] = CRGB::Green; /* outer array (dir) refers to each direction strip */
    }
    else if (col == 3) {
      leds_Strips[dir][deg] = CRGB::Blue; /* inner array (deg) refers to one of the 23 LEDs in each direction strip */
    }
  }
}

/* function to scan for valid degree entries and alter all entries to positional numbering scheme */
int checkDegree(int dir, int deg) {
  if (dir == 8) { /* leds_Center will only ever have 1 LED in it */
    if (deg == 0) { /* the only accepted entry for center deg is 0 */
      //Serial.println("Valid degree entry."); /* since degree offset is measured wrt center LED */
    }
    else { /* if any other entry for deg of center LED (dir = 8) */
      //Serial.println("Invalid degree entry for center LED."); /* invalid entry */
    }
  }
  else { /* if accessing anything except the center LED */
    if (deg > 20) { /* if outside the section of LEDs in a strip that have 1 degree separation */
      if (deg == 25) { /* if degree offset from center LED is 25 */
        ledNum = 20; /* change deg to 20 - that is the position in the strip assigned to LED with 25 degree offset */
        //Serial.println("Valid degree entry.");
      }
      else if (deg == 30) { /* if degree offset is 30 */
        ledNum = 21; /* change deg to 21 */
        //Serial.println("Valid degree entry.");
      }
      else if (deg == 35) { /*if degree offset is 35 */
        ledNum = 22; /* change deg to 22 */
        //Serial.println("Valid degree entry.");
      }
      else if (deg > 35) { /* no LEDs beyond a 35 degree offset */
        ledNum = -1; /* assign arbitrary placeholder deg of -1 */
        //Serial.println("Error. Inputs exceeds limits."); /* so invalid */
      }
      else if ((deg > 20 && deg < 25) || (deg > 25 && deg < 30) || (deg > 30 && deg < 35)) { /* no LEDs between 20 and 25 or 25 and 30 or 30 and 35 degrees */
        ledNum = -1; /* assign arbitrary placeholder deg of -1 so they won't light up */
        //Serial.println("Error. Degree entry not an option."); /* so invalid */
      }
    }
    else { /* in any other case */
      ledNum = deg - 1; /* convert degree offset entry to positional number */
      //Serial.println("Valid degree entry."); /* example: entry of deg = 1 refers to leds[0], entry of deg = 20 refers to leds[19] */
    }
    return ledNum;
  }
}

/* simple function to turnOn LED
   meant to make action of FastLED.show() more transparent
*/
void turnOnLED() {
  FastLED.show(); /* display the color selections set in setColor() */
}

/* function to turn off LEDs
  regardless of whether in leds_Center or leds_Strips
*/
void turnOff(int dir, int ledNum) {
  if (dir == 8) {
    leds_Center[0] = CRGB::Black; FastLED.show(); /* set LED to black, then display */
  }
  else {
    leds_Strips[dir][ledNum] = CRGB::Black; FastLED.show();
  }
}


void setup() {

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

  /*set serial data transmission rate (baud rate)*/
  Serial.begin(9600);

  Serial.println("Ready");

}

void loop() {
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
    switch ((int) *command) { /*switch case based on first command*/
      case 1: //sendPhaseParams:dir:color:degree:timeon
        {
          dir = * (command + 1);
          color = * (command + 2);
          int deg = * (command + 3);
          timeOn = * (command + 4) * 1000;

          ledNum = checkDegree(dir, deg);
          setColor(dir, color, deg);
        }
        break;
      case 2: //showLEDs
        {
          turnOnLED();
          delay(timeOn);
          turnOff(dir, ledNum);
        }
        break;
    }
  }
}
