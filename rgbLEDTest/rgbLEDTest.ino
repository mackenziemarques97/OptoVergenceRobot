int ledDelay = 1000;

#define RED 3
#define GREEN 4
#define BLUE 5

void setup() {
  pinMode(RED, OUTPUT);
  pinMode(BLUE, OUTPUT);
  pinMode(GREEN, OUTPUT);
  analogWrite(RED, 255);
  analogWrite(GREEN, 255);
  analogWrite(BLUE, 255);

  Serial.begin(9600);
}

void loop() {
  int ledColor = random(3);
  Serial.println(ledColor);
  switch (ledColor) {
    case 0://RED
      analogWrite(RED, 200);
      delay(ledDelay);
      analogWrite(RED, 255);
      break;
    case 1://BLUE
      analogWrite(BLUE, 200);
      delay(ledDelay);
      analogWrite(BLUE, 255);
      break;
    case 2://GREEN
      analogWrite(GREEN, 200);
      delay(ledDelay);
      analogWrite(GREEN, 255);
      break;
  }
}
