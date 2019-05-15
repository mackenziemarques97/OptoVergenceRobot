#include <stdio.h>
#include <math.h>
/*define LED pins*/
#define RED 48
#define BLUE 49
#define GREEN 50

float forward_coeffs[16]; /*used in delayToSpeed function*/
float reverse_coeffs[16]; /*used in speedToDelay function*/

/*Blink an LED twice
   input: specific LED pin
   that pin must be set to HIGH before calling this function
*/
void Blink(int LED) {
  digitalWrite(LED, LOW);
  delay(1000);
  digitalWrite(LED, HIGH);
  delay(1000);
  digitalWrite(LED, LOW);
  delay(1000);
  digitalWrite(LED, HIGH);
}

/*confirm serial connection function
   initialize serialInit as X
   send A to MATLAB
   expecting to receive A
   if doeS not receive A, then continue reading COM port and blinking red LED
*/
void initialize() {
  char serialInit = 'X';
  Serial.println("A");
  while (serialInit != 'A')
  {
    serialInit = Serial.read();
    pinMode(RED, HIGH);
    Blink(RED);
  }
}

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
        Serial.println("ForwardCoeffsReceived");
        pinMode(GREEN, HIGH);
        Blink(GREEN);
      }
      if (*coeffs == 2) {/*if the reverse_coeffs has been received from MATLAB*/
        pinMode(RED, HIGH);
        Blink(RED);
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

void setup() {
  pinMode(RED, OUTPUT);
  pinMode(BLUE, OUTPUT);
  pinMode(GREEN, OUTPUT);
  pinMode(RED, LOW);
  pinMode(BLUE, LOW);
  pinMode(GREEN, LOW);

  Serial.begin(9600);

  initialize();
  Serial.println("Z");
  pinMode(BLUE, HIGH);
  Blink(BLUE);

  loadInfo();
  Serial.println("Ready");
}

void loop() {
  String incoming = Serial.readString();
  if (incoming != NULL) {
    char incomingChar[incoming.length() + 1];
    incoming.toCharArray(incomingChar, incoming.length() + 1);
    Serial.println(incoming);
  }
}
