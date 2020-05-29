/*SAMPLE COMMANDS

   oneLED:N:green:4:3 - in the N strip, the 4th LED counting away from center
   turns on green for 3 seconds, then turns off

   saccade:1:N:red:1:3:NW:green:13:3 - the 1st LED in the N strip turns on red
   for 3 seconds, turns off, 13th LED in NW strip turns on green for 3 seconds,
   then turns off

   saccade:2:N:red:1:3:SE:green:20:3 - the 1st LED in the N strip lights up red
   for 3 seconds, the 13th LED in SE strip lights up green for 3 seconds,
   then both LEDs turn off

  NOTE: Saccade command including S and SE lights up extraneous LEDs at end of run.

   smoothPursuit:N:blue:1:16 - 1st LED in N strip lights up blue,
   the light moves down the strip to the 16th LED, then shuts off
*/

/*
   1st command entry of an array is in position 0
   1st entry = array[0]
   i = 0
*/

/*
    code only deals with red, blue, and green LEDs
    more can be added later if user wants
*/

/*
    most functions contain if statements controlling for direction
    to determine whether the the command is being sent to a direction strip
    or to the center LED since there are different arrays for center LED vs. strips
*/

#include <stdio.h>
#include <math.h>
#include <FastLED.h>

#define BRIGHTNESS  100 /* valid values between 0 and 255 */
#define LED_TYPE    WS2812B
#define COLOR_ORDER GRB

/*define number of direction strips*/
#define NUM_STRIPS 8
/*define number of LEDs in each direction strip*/
#define NUM_LEDS_PER_STRIP 23
/*define one LED in the center*/
#define NUM_Center 1

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

/*create an array of LED arrays to represent the direction strips*/
CRGB leds_Strips[NUM_STRIPS][NUM_LEDS_PER_STRIP]; /* CRGB is an object representing a color in RGB color space */
/*create an array for center LED*/
CRGB leds_Center[NUM_Center];
/*declare String object where input commands are read into*/
String str;

/*function to confirm serial connection
   initialize serialInit as X
   send A to MATLAB
   expecting to receive A
   if does not receive A, then continue reading COM port
*/
void initialize() {
  char serialInit = 'X';
  Serial.println("A");
  Serial.println("Type A, then press enter.");
  while (serialInit != 'A')
  {
    serialInit = Serial.read();
  }
}

/* function to parse inputs for controlling LED into pointer variable */
/* command numbering - 0:1:2:3:4:5... */
double* parseLEDcommand(char strCommand[]) {
  const char delim[2] = ":"; /*delimiter between inputs declared as :*/
  char *token;
  token = strtok(strCommand, delim);
  if (strcmp(token, "oneLED") == 0) { /*switch case 1 - oneLED*/
    static double command[5]; /*5 numerical double command entries are required - oneLED:direction:color:degree offset:time on*/
    command[0] = 1; /*first number in command array indicates switch case ( 1 = oneLED )*/
    int i = 1;
    while (token != NULL) {
      token = strtok(NULL, delim);
      /*the following if statement assigns numbers to string command entries*/
      if (i == 1) { /* i = 1 indicates 2nd command entry - if looping through and parsing 2nd command entry */
        /* integers in command[1] indicate directions */
        /* case/capitalization matters */
        if (strcmp(token, "N") == 0) { /* if 2nd command entry is N */
          command[i] = 0; /* put 0 in position 1 of command[] */
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "NW") == 0) { /* if 2nd command entry is NW */
          command[i] = 1; /* put 1 in command[1] */
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "NE") == 0) { /* if 2nd command entry is NE */
          command[i] = 2; /* put 2 in command[1] */
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "S") == 0) { /* if 2nd command entry is S */
          command[i] = 3; /* put 3 in command[1] */
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "SW") == 0) { /* if 2nd command entry is SW */
          command[i] = 4; /* put 4 in command[1] */
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "SE") == 0) { /* if 2nd command entry is SE */
          command[i] = 5; /* put 5 in command[1] */
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "W") == 0) { /* if 2nd command entry is W */
          command[i] = 6; /* put 6 in command[1] */
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "E") == 0) { /* if 2nd command entry is E */
          command[i] = 7; /* put 7 in command[1] */
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "center") == 0) { /* if 2nd command entry is center */
          command[i] = 8; /* put 8 in command[1] */
          Serial.println("Valid direction entry.");
          i++;
        }
        else { /* if the 2nd command entry is anything other than N,NW,NE,S,SW,SE,W,E,center */
          command[i] = -1; /* put arbitrary placeholder -1 in command[1] */
          Serial.println("Invalid direction entry."); /* is an invlaid direction entry */
          i++;
        }
      }
      else if (i == 2) { /* i = 2 indicates 3rd command entry - if looping through and parsing 3nd command entry */
        /* integers in command[2] indicate LED colors */
        /* case/capitalization matters */
        if (strcmp(token, "red") == 0) { /* if 3rd command entry is red */
          command[i] = 1; /* put 1 in command[2] */
          Serial.println("Valid color entry.");
          i++;
        }
        else if (strcmp(token, "green") == 0) { /* if 3rd command entry is green */
          command[i] = 2; /* put 2 in command[2] */
          Serial.println("Valid color entry.");
          i++;
        }
        else if (strcmp(token, "blue") == 0) { /* if 3rd command entry is blue */
          command[i] = 3; /* put 3 in command[2] */
          Serial.println("Valid color entry.");
          i++;
        }
        else { /* otherwise */
          command[i] = -1; /* put arbitrary,placeholder -1 in command[2] */
          Serial.print("Invalid color entry. "); /* is an invalid color entry */
          i++;
        }
      }
      else { /* for rest of command entries (which should be integers) */
        command[i++] = atof(token); /* put them in command array */
      }
    }
    return command;
  }
  if (strcmp(token, "saccade") == 0) { /* switch case 2 - saccade */
    static double command[10]; /* 10 numerical double command entries are required - saccade:2ndswitchcase:dir1:col1:deg1:LED1timeon:LED2dir:LED2color:LED2degree:LED2timeon*/
    command[0] = 2; /* command 0 indicates switch case (2 = saccade) */
    int i = 1;
    while (token != NULL) {
      token = strtok(NULL, delim);
      /* same directions numbering scheme as oneLED */
      if (i == 2 || i == 6) { /* commands 2 and 6 are directions */
        if (strcmp(token, "N") == 0) {
          command[i] = 0;
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "NW") == 0) {
          command[i] = 1;
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "NE") == 0) {
          command[i] = 2;
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "S") == 0) {
          command[i] = 3;
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "SW") == 0) {
          command[i] = 4;
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "SE") == 0) {
          command[i] = 5;
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "W") == 0) {
          command[i] = 6;
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "E") == 0) {
          command[i] = 7;
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "center") == 0) {
          command[i] = 8;
          Serial.println("Valid direction entry.");
          i++;
        }
        else {
          command[i] = -1;
          Serial.print("Invalid direction entry."); Serial.println(i);
          i++;
        }
      }
      /* same coloring numbering scheme as oneLED */
      else if (i == 3 || i == 7) {
        if (strcmp(token, "red") == 0) {
          command[i] = 1;
          Serial.println("Valid color entry.");
          i++;
        }
        else if (strcmp(token, "green") == 0) {
          command[i] = 2;
          Serial.println("Valid color entry.");
          i++;
        }
        else if (strcmp(token, "blue") == 0) {
          command[i] = 3;
          Serial.println("Valid color entry.");
          i++;
        }
        else {
          command[i] = -1;
          Serial.println("Invalid color entry.");  Serial.println(i);
          i++;
        }
      }
      else {
        command[i++] = atof(token);
      }
    }
    return command;
  }
  if (strcmp(token, "smoothPursuit") == 0) { /* switch case 3 - smoothPursuit */
    static double command[4]; /*4 numerical double command entries are required - smoothPursuit:dir:col:degInit:degFinal */
    command[0] = 3; /* command 0 indicates switch case (3 = smoothPursuit) */
    int i = 1;
    while (token != NULL) {
      token = strtok(NULL, delim);
      /* same directions numbering scheme as oneLED and saccade */
      if (i == 1) {
        if (strcmp(token, "N") == 0) {
          command[i] = 0;
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "NW") == 0) {
          command[i] = 1;
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "NE") == 0) {
          command[i] = 2;
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "S") == 0) {
          command[i] = 3;
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "SW") == 0) {
          command[i] = 4;
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "SE") == 0) {
          command[i] = 5;
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "W") == 0) {
          command[i] = 6;
          Serial.println("Valid direction entry.");
          i++;
        }
        else if (strcmp(token, "E") == 0) {
          command[i] = 7;
          Serial.println("Valid direction entry.");
          i++;
        }
        else {
          command[i] = -1;
          Serial.print("Invalid direction entry. ");
          i++;
        }
      }
      /* same directions numbering scheme as oneLED and saccade */
      else if (i == 2) {
        if (strcmp(token, "red") == 0) {
          command[i] = 1;
          Serial.println("Valid color entry.");
          i++;
        }
        else if (strcmp(token, "green") == 0) {
          command[i] = 2;
          Serial.println("Valid color entry.");
          i++;
        }
        else if (strcmp(token, "blue") == 0) {
          command[i] = 3;
          Serial.println("Valid color entry.");
          i++;
        }
        else {
          command[i] = -1;
          Serial.print("Invalid color entry. ");
          i++;
        }
      }
      else {
        command[i++] = atof(token);
      }
    }
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
      Serial.println("Valid degree entry."); /* since degree offset is measured wrt center LED */
    }
    else { /* if any other entry for deg of center LED (dir = 8) */
      Serial.println("Invalid degree entry for center LED."); /* invalid entry */
    }
  }
  else { /* if accessing anything except the center LED */
    if (deg > 20) { /* if outside the section of LEDs in a strip that have 1 degree separation */
      if (deg == 25) { /* if degree offset from center LED is 25 */
        deg = 20; /* change deg to 20 - that is the position in the strip assigned to LED with 25 degree offset */
        Serial.println("Valid degree entry.");
      }
      else if (deg == 30) { /* if degree offset is 30 */
        deg = 21; /* change deg to 21 */
        Serial.println("Valid degree entry.");
      }
      else if (deg == 35) { /*if degree offset is 35 */
        deg = 22; /* change deg to 22 */
        Serial.println("Valid degree entry.");
      }
      else if (deg > 35) { /* no LEDs beyond a 35 degree offset */
        deg = -1; /* assign arbitrary placeholder deg of -1 */
        Serial.println("Error. Inputs exceeds limits."); /* so invalid */
      }
      else if ((deg > 25 && deg < 30) || (deg > 30 && deg < 35)) { /* no LEDs between 25 and 30 or 30 and 35 degrees */
        deg = -1; /* assign arbitrary placeholder deg of -1 */
        Serial.println("Error. Degree entry not an option."); /* so invalid */
      }
    }
    else { /* in any other case */
      deg = deg - 1; /* convert degree offset entry to positional number */
      Serial.println("Valid degree entry."); /* example: entry of deg = 1 refers to leds[0], entry of deg = 20 refers to leds[19] */
    }
    return deg;
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
void turnOff(int dir, int deg) {
  if (dir == 8) {
    leds_Center[0] = CRGB::Black; FastLED.show(); /* set LED to black, then display */
  }
  else {
    leds_Strips[dir][deg] = CRGB::Black; FastLED.show();
  }
}

void setup() {
  Serial.begin(9600); /* opens serial port, sets data rate to 9600 bps */

  initialize(); /* confirms serial connection */
  Serial.println("Ready for commands.");
  delay( 3000 ); /* power-up safety delay */

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
}

void loop() {
  Serial.flush();
  str = Serial.readString(); /* read characters from command entries into a String object */

  if (str != NULL) { /* if serial buffer is not empty */
    char inputArray[str.length() + 1]; /* creates character array one space larger than str */
    str.toCharArray(inputArray, str.length() + 1); /* converts str from String object to null terminated character array */
    double *command = parseLEDcommand(inputArray); /* creates pointer variable to commands parsed from entries */
    switch ((int) *command ) { /* primary switch case based on 1st entry in command */
      case 1: //oneLED:direction:color:degree offset from center:time on in seconds
        {
          int dir = *(command + 1); /* identifies direction strand */
          int col = *(command + 2); /* identifies color */
          int deg = *(command + 3); /* identifies degree offset from center LED */
          int timeOn = *(command + 4) * 1000; /* identifies time between turning on and truning off LED */
          /* entry will be in seconds, convert to milliseconds */
          deg = checkDegree(dir, deg); /* checks the degree entered */
          setColor(dir, col, deg); /* sets the color of LED (LED specified by dir and deg) */
          turnOnLED(); /* turns on LED / displays any color changes made */
          delay(timeOn); /* waits */
          turnOff(dir, deg); /* turns off LED, specified by dir and deg */
          break;
        }
      case 2: //saccade:1 (2ndaryswitchcase):LED1dir:LED1color:LED1degree:LED1timeon:LED2dir:LED2color:LED2degree:LED2timeon
        {
          switch ((int) * (command + 1)) { /* secondary switch case based on 2nd entry in command */
            case 1: /* turn on fixation LED for given amount of time, turn off, turn on 2nd LED for given amount of time, turn off */
              {
                int dir1 = *(command + 2); /* identifies direction strand of fixation point */
                int col1 = *(command + 3); /* identifies color of fixation point */
                int deg1 = *(command + 4); /* identifies degree offset of fixation point */
                int timeOn1 = *(command + 5) * 1000; /* identifies time between turning on and turning off fixation point */
                int dir2 = *(command + 6); /* assigns direction strand of 2nd LED */
                int col2 = *(command + 7); /* assigns color of 2nd LED */
                int deg2 = *(command + 8); /* assigns degree offset of 2nd LED */
                int timeOn2 = *(command + 9) * 1000; /* assigns time between turning on and off 2nd LED */
                deg1 = checkDegree(dir1, deg1); /* checks degree of fixation point */
                setColor(dir1, col1, deg1); /* sets color of fixation point */
                turnOnLED(); /* turns on fixation LED */
                delay(timeOn1); /* waits */
                turnOff(dir1, deg1); /* turn off fixation LED */
                deg2 = checkDegree(dir2, deg2); /* checks degree of 2nd LED */
                setColor(dir2, col2, deg2); /* sets color of 2nd LED */
                turnOnLED(); /* turns on 2nd LED */
                delay(timeOn2); /* waits */
                turnOff(dir2, deg2); /* turns off 2nd LED */
                break;
              }
            case 2: //saccade:2 (2ndaryswitchcase):LED1dir:LED1color:LED1degree:LED1timeBeforeLED2:LED2dir:LED2color:LED2degree:timeLED1&2OnFor
              {
                int dir1 = *(command + 2); /* identifies direction strand of fix point LED */
                int col1 = *(command + 3); /* identifies color of fix point LED */
                int deg1 = *(command + 4); /* identifies deg offset of fix point */
                int timeOn1 = *(command + 5) * 1000; /* identifies wait time before turning on 2nd LED */
                int dir2 = *(command + 6); /* identifies direction strand of 2nd LED */
                int col2 = *(command + 7); /* identifies color of 2nd LED */
                int deg2 = *(command + 8); /* idetifies deg offset of 2nd LED */
                int timeOn2 = *(command + 9) * 1000; /* identitifes wait time before turning off both fix and 2nd LED */
                deg1 = checkDegree(dir1, deg1); /* checks deg offset of fix LED */
                setColor(dir1, col1, deg1); /* sets color of fix LED */
                turnOnLED(); /* turns on fix LED */
                delay(timeOn1); /* waits */
                deg2 = checkDegree(dir2, deg2); /* checks deg of 2nd LED */
                setColor(dir2, col2, deg2); /* sets color of 2nd LED */
                turnOnLED(); /* turns on 2nd LED */
                delay(timeOn2); /* waits */
                turnOff(dir1, deg1); /* turns off fix LED */
                turnOff(dir2, deg2); /* turns off 2nd LED */
                break;
              }
          }
        }
      case 3: {//smoothPursuit:dir:col:degInit:degFinal
          /* moves light down a strip */
          int dir = *(command + 1); /* identifies direction strand */
          int col = *(command + 2); /* identifies LED color */
          int degInit = *(command + 3); /* identifies deg offset of starting LED */
          int degFinal = *(command + 4) + 1; /* identifies deg offset of ending LED */
          for ( int i = degInit; i < degFinal; i++ ) { /* loops through LEDs from initial to final */
            int deg = checkDegree(dir, i); /* checks each degree */
            setColor(dir, col, deg); /* sets color */
            turnOnLED(); /* turns on LED */
            FastLED.delay(60); /* delays for 60 ms */
            turnOff(dir, deg); /* turns off LED */
          }
        }
    }
  }
}
