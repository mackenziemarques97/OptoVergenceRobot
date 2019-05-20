/*confirm serial connection function
   initialize serialInit as X
   send A to MATLAB
   expecting to receive A
   if doeS not receive A, then continue reading COM port and blinking red LED
*/

/* upper limit of delay storage is 55
 * in current data format - float
 */
float delay_array[56] = {};


void initialize() {
  char serialInit = 'X';
  Serial.println("A");
  while (serialInit != 'A')
  {
    serialInit = Serial.read();
    //Blink(RED);
  }
}

/*loadInfo function
   receive forward_ & reverse_coeffs strings sent from MATLAB
   parse coeffs into designated arrays
   first string defined as pointer variable
   once reverse_coeffs has been received, break from while loop
*/
void loadInfo() {
  Serial.println("ReadyToReceiveDelays"); /*signal MATLAB to begin send coeffs*/
  while (1) { /*loop through infinitely*/
    String coeffsString = Serial.readString();/*read characters from serial connection into String object*/
    /*this section of code is nearly identical to part of parseCommand function above*/
    if (coeffsString != NULL) {
      char inputArray[coeffsString.length() + 1];
      coeffsString.toCharArray(inputArray, coeffsString.length() + 1);
      float *delays = parseCoeffs(inputArray);
      if (*delays == 55) {
        Serial.println("DelaysReceived");
        //Serial.println(delay_array[3]);
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
  if (strcmp(strtokIn, "Delays") == 0) {
    static float coeffsArray[56]; /*preallocate space for designating forward or reverse coeffs and number of coefficients total*/
    coeffsArray[0] = 55;
    int i = 1;
    while (strtokIn != NULL) {
      strtokIn = strtok(NULL, delim);
      coeffsArray[i++] = atof(strtokIn);
    }
    for (i = 0; i < 55; i++) {
      delay_array[i] = coeffsArray[i];
    }
    return coeffsArray;
  }
}

void setup() {
  Serial.begin(9600);
  //Serial.println(delay_array[62]);
  initialize();
  loadInfo();
  //Serial.println(delay_array[3]);
}

void loop() {

  //loadInfo();
}
