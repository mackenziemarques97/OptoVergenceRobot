int ledDelay = 1000; // how long LED is on for in each flash, 1000 ms, 1 s

// set LED pins
#define RED 48
#define GREEN 49
#define BLUE 50
// set brightness of LED between 0 and 255
// entry of 127 results in visible light, 128 does not
int onBrightness = 127;
// set value for LED to be off, depending on common anode or cathode LED
int off = 255;

void setup() {
  // define LED pins as output pins
  pinMode(RED, OUTPUT);
  pinMode(BLUE, OUTPUT);
  pinMode(GREEN, OUTPUT);
  // start with LEDs off
  analogWrite(RED, off);
  analogWrite(GREEN, off);
  analogWrite(BLUE, off);
  // set baud rate for serial data transmission
  Serial.begin(9600);
}

void loop() {
  int ledColor = random(3); // assign random number between 0 and 2 to variable ledColor
  Serial.println(ledColor); // print ledColor switch case number
  switch (ledColor) {
    case 0://RED
      analogWrite(RED, onBrightness);
      delay(ledDelay); //wait 1 sec
      analogWrite(RED, off); //off
      break;
    case 1://BLUE
      analogWrite(BLUE, onBrightness);
      delay(ledDelay); //wait 1 sec
      analogWrite(BLUE, off); //off
      break;
    case 2://GREEN
      analogWrite(GREEN, onBrightness);
      delay(ledDelay); //wait 1 sec
      analogWrite(GREEN, off); //off
      break;
  }
}
