/* Include the following libraries */
#include <stdio.h>
#include <math.h>
#include <FastLED.h>

/*LED pins on Arduino for each direction strip*/
#define N_Strip 40 //bluewhite
#define NW_Strip 41 //yellowblack
#define NE_Strip 42 //black
#define S_Strip 43 //purple
#define SW_Strip 44 //greenwhite
#define SE_Strip 45 //brown
#define W_Strip 46 //white
#define E_Strip 47 //blue
/*LED pin on Arduino for center LED*/
#define Center 48 //brownblack

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
int ledNum;
double dirIndex, colIndex;
String val;

double dirCheck(const char* token) {
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

double colCheck(const char* token) {
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
        command[i] = dirCheck(token);
        i++;
      }
      else if (i == 2) { /* i = 2 indicates 3rd command entry - if looping through and parsing 3nd command entry */
        command[i] = colCheck(token);
        i++;
      }
      else { /* for rest of command entries (which should be integers) */
        command[i++] = atof(token); /* put them in command array */
      }
    }
  
  return command;
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
      case 1: //sendPhaseParams
        {
          for (int i = 1; i < 5; i++) {
            Serial.println(*(command + i));
          }
        }
        break;
    }
  }
}
