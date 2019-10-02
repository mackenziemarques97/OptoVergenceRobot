/*Isolated code for testing speedToDelay model in Arduino*/

float pi = 3.14159265359; /*numerical approximation used for pi*/
int stepsPerRev = 200; /*steps per revolution, for converting b/w cm input to steps*/
unsigned long microstepsPerStep = 16; /*divides each step into this many microsteps (us), determined by microstepping settings on stepper driver, (16 us/step)*(200 steps/rev)corresponds to 3200 pulse/rev*/
unsigned long dimensions[2] = {30000 * microstepsPerStep, 30000 * microstepsPerStep}; /*preallocating dimensions to previously measured values, arbitrary initialization value*/
double forward_coeffs[16]; /*used in delayToSpeed function*/
double reverse_coeffs[16]; /*used in speedToDelay function*/

/* Defines scaling factor for rotation
    radius of pulley
    will be multiplied by 2pi later in the code to get circumference
*/
float motor_radius = 0.65; //cm
float Circ = 2 * pi * motor_radius; /*circumference of pulley*/

double Speed = 1327;
double angle = 45;

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
      }
      if (*coeffs == 2) {/*if the reverse_coeffs has been received from MATLAB*/
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

void setup() {
  /*set serial data transmission rate (baud rate)*/
  Serial.begin(9600);
  /* Communicates with Serial connection to verify */
  initialize();
  /* Sends coefficients for speed model */
  loadInfo();
  dimensions[0] = 106528;//*i * microstepsPerStep; /*x-dimension*/
  dimensions[1] = 54624;//*(i + 1) * microstepsPerStep; /*y-dimension*/
  Serial.println("Ready");
  double del = speedToDelay(reverse_coeffs, Speed, angle);

  Serial.print("Speed = "); Serial.println(Speed);
  Serial.print("angle = "); Serial.println(angle);
  Serial.print("delay = "); Serial.println(del);
}

void loop() {
  // put your main code here, to run repeatedly:

}
